#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════
#  🎬 سينمانا — لوحة التحكم الاحترافية
# ═══════════════════════════════════════════════════════════════════════════
#  الإصدار:   4.0
#  المؤلف:    B6_7E | بيكاس
#  الحقوق:    © 2025 B6_7E | بيكاس — جميع الحقوق محفوظة
#  الترخيص:   خاص — يُحظر إعادة التوزيع دون إذن كتابي
#
#  المنصات:
#    ✓ NewTerm iOS  (بدون Python)   ✓ Termux Android
#    ✓ Linux                         ✓ macOS
#
#  المتطلبات:  sh · git · sed · awk · wc · tr   (كلها متوفرة افتراضياً)
#
#  الاستخدام:
#    chmod +x cinepanel.sh && ./cinepanel.sh
# ═══════════════════════════════════════════════════════════════════════════

set -u

VERSION="4.0"
AUTHOR="B6_7E | بيكاس"
COPYRIGHT="© 2025 $AUTHOR — جميع الحقوق محفوظة"

# ─────────────────────────────── الإعدادات ───────────────────────────────
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR" 2>/dev/null || {
    printf 'تعذر الانتقال إلى مجلد المشروع\n' >&2
    exit 1
}

DATA_DIR="data"
DB_MOVIES="$DATA_DIR/movies.db"
DB_CHANNELS="$DATA_DIR/channels.db"
JSON_MOVIES="$DATA_DIR/movies.json"
JSON_CHANNELS="$DATA_DIR/channels.json"
CONTENT_JS="$DATA_DIR/content.js"
GIT_MSG="Init"

mkdir -p "$DATA_DIR" 2>/dev/null

# فاصل الحقول (ASCII 31 — Unit Separator) — آمن لروابط/عناوين
US=$(printf '\037')

# ─────────────────────────────── الألوان ───────────────────────────────
R='\033[0m';   BOLD='\033[1m'; DIM='\033[2m'
RED='\033[31m'; GRN='\033[32m'; YEL='\033[33m'
BLU='\033[34m'; MAG='\033[35m'; CYN='\033[36m'; WHT='\033[37m'

clear_screen() {
    command -v clear >/dev/null 2>&1 && clear 2>/dev/null || printf '\033[2J\033[H'
}

# ─────────────────────────────── الإشعارات ───────────────────────────────
notify() {
    ntf_title="$1"
    ntf_msg="$2"

    # 1) رنة طرفية (iOS: قد تصدر صوتاً حسب إعدادات التطبيق)
    printf '\a'
    # 2) تحديث عنوان التاب/النافذة (يدعمه NewTerm)
    printf '\033]0;%s\007' "$ntf_title"
    # 3) بانر مرئي
    printf '\n%b╭──────────────────────────────────────╮%b\n' "$CYN" "$R"
    printf '%b│%b %b🔔 %s%b\n' "$CYN" "$R" "$BOLD" "$ntf_title" "$R"
    printf '%b│%b %s\n'        "$CYN" "$R" "$ntf_msg"
    printf '%b╰──────────────────────────────────────╯%b\n' "$CYN" "$R"
    # 4) إشعار نظام على macOS (يتخطى بأمان على iOS)
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$ntf_msg\" with title \"$ntf_title\"" >/dev/null 2>&1 &
    fi
}

# ─────────────────────────────── أدوات JSON ───────────────────────────────
json_escape() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# ─────────────────── توليد movies.json من DB ───────────────────
save_movies_json() {
    mj_first=1
    {
        printf '{\n  "movies": [\n'
        if [ -s "$DB_MOVIES" ]; then
            while IFS="$US" read -r mv_title mv_year mv_genre mv_rating mv_poster mv_story mv_url mv_label; do
                [ -z "${mv_title:-}" ] && continue
                if [ "$mj_first" -eq 1 ]; then mj_first=0; else printf '    },\n'; fi
                printf '    {\n'
                printf '      "title": "%s",\n'  "$(json_escape "$mv_title")"
                printf '      "year": %s,\n'     "${mv_year:-0}"
                printf '      "genre": "%s",\n'  "$(json_escape "${mv_genre:-عام}")"
                printf '      "rating": %s,\n'   "${mv_rating:-0}"
                printf '      "poster": "%s",\n' "$(json_escape "${mv_poster:-}")"
                printf '      "story": "%s",\n'  "$(json_escape "${mv_story:-}")"
                printf '      "sources": [\n        {\n'
                printf '          "label": "%s",\n' "$(json_escape "${mv_label:-سيرفر رئيسي}")"
                printf '          "url": "%s"\n'    "$(json_escape "${mv_url:-}")"
                printf '        }\n      ]\n'
            done < "$DB_MOVIES"
        fi
        [ "$mj_first" -eq 0 ] && printf '    }\n'
        printf '  ]\n}\n'
    } > "$JSON_MOVIES"
}

# ─────────────────── توليد channels.json من DB ───────────────────
save_channels_json() {
    cj_first=1
    {
        printf '{\n  "channels": [\n'
        if [ -s "$DB_CHANNELS" ]; then
            while IFS="$US" read -r ch_name ch_poster ch_stream ch_desc; do
                [ -z "${ch_name:-}" ] && continue
                if [ "$cj_first" -eq 1 ]; then cj_first=0; else printf '    },\n'; fi
                printf '    {\n'
                printf '      "name": "%s",\n'   "$(json_escape "$ch_name")"
                printf '      "poster": "%s",\n' "$(json_escape "${ch_poster:-}")"
                printf '      "stream": "%s",\n' "$(json_escape "${ch_stream:-}")"
                printf '      "desc": "%s",\n'   "$(json_escape "${ch_desc:-}")"
                printf '      "sources": [\n        {\n'
                printf '          "label": "سيرفر مباشر",\n'
                printf '          "url": "%s"\n' "$(json_escape "${ch_stream:-}")"
                printf '        }\n      ]\n'
            done < "$DB_CHANNELS"
        fi
        [ "$cj_first" -eq 0 ] && printf '    }\n'
        printf '  ]\n}\n'
    } > "$JSON_CHANNELS"
}

# ─────────────────── توليد content.js من DB ───────────────────
save_content_js() {
    {
        printf '/* © 2025 B6_7E | بيكاس — %s */\n' "$COPYRIGHT"
        printf 'window.__CINEMA_DATA__ = {\n'

        # Movies
        printf '  "movies": ['
        cjs_first=1
        if [ -s "$DB_MOVIES" ]; then
            while IFS="$US" read -r mv_title mv_year mv_genre mv_rating mv_poster mv_story mv_url mv_label; do
                [ -z "${mv_title:-}" ] && continue
                [ "$cjs_first" -eq 0 ] && printf ','
                cjs_first=0
                printf '\n    {"title":"%s","year":%s,"genre":"%s","rating":%s,"poster":"%s","story":"%s","sources":[{"label":"%s","url":"%s"}]}' \
                    "$(json_escape "$mv_title")" "${mv_year:-0}" \
                    "$(json_escape "${mv_genre:-عام}")" "${mv_rating:-0}" \
                    "$(json_escape "${mv_poster:-}")" "$(json_escape "${mv_story:-}")" \
                    "$(json_escape "${mv_label:-سيرفر رئيسي}")" "$(json_escape "${mv_url:-}")"
            done < "$DB_MOVIES"
        fi
        printf '\n  ],\n'

        # Channels
        printf '  "channels": ['
        cjs_first=1
        if [ -s "$DB_CHANNELS" ]; then
            while IFS="$US" read -r ch_name ch_poster ch_stream ch_desc; do
                [ -z "${ch_name:-}" ] && continue
                [ "$cjs_first" -eq 0 ] && printf ','
                cjs_first=0
                printf '\n    {"name":"%s","poster":"%s","stream":"%s","desc":"%s","sources":[{"label":"سيرفر مباشر","url":"%s"}]}' \
                    "$(json_escape "$ch_name")" "$(json_escape "${ch_poster:-}")" \
                    "$(json_escape "${ch_stream:-}")" "$(json_escape "${ch_desc:-}")" \
                    "$(json_escape "${ch_stream:-}")"
            done < "$DB_CHANNELS"
        fi
        printf '\n  ]\n};\n'
    } > "$CONTENT_JS"
}

save_all() {
    save_movies_json
    save_channels_json
    save_content_js
}

# ─────────────────────────────── Git ───────────────────────────────
git_push() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        notify "⚠ Git" "ليس مستودع git — تخطي الرفع"
        return 1
    fi
    git add --all >/dev/null 2>&1
    if git diff --cached --quiet >/dev/null 2>&1; then
        notify "ℹ GitHub" "لا توجد تغييرات جديدة"
        return 0
    fi
    if ! git commit -m "$GIT_MSG" >/dev/null 2>&1; then
        notify "✗ Git" "فشل commit"
        return 1
    fi
    gp_out=$(git push 2>&1)
    if [ $? -eq 0 ]; then
        notify "✓ GitHub" "تم الرفع بنجاح"
        return 0
    else
        notify "✗ GitHub" "فشل الرفع — تحقّق من الاتصال"
        printf '%s\n' "$gp_out" | tail -5 | sed 's/^/  /'
        return 1
    fi
}

# ─────────────────────────────── إدخال ───────────────────────────────
ask() {
    ask_prompt="$1"
    ask_default="$2"
    ask_input=""
    if [ -n "$ask_default" ]; then
        printf '%b%s%b %b[%s]%b: ' "$WHT" "$ask_prompt" "$R" "$DIM" "$ask_default" "$R"
    else
        printf '%b%s%b: ' "$WHT" "$ask_prompt" "$R"
    fi
    IFS= read -r ask_input || ask_input=""
    if [ "$ask_input" = "--" ]; then
        ask_input=""
    elif [ -z "$ask_input" ] && [ -n "$ask_default" ]; then
        ask_input="$ask_default"
    fi
    ASK_RESULT="$ask_input"
}

pause_enter() {
    printf '\n%bاضغط Enter للمتابعة...%b' "$DIM" "$R"
    IFS= read -r _ || true
}

# ─────────────────────────────── قوائم ───────────────────────────────
list_movies() {
    if [ ! -s "$DB_MOVIES" ]; then
        printf '  %b(لا توجد أفلام بعد)%b\n' "$DIM" "$R"
        return
    fi
    lm_i=0
    while IFS="$US" read -r mv_title mv_year mv_genre mv_rating mv_poster mv_story mv_url mv_label; do
        [ -z "${mv_title:-}" ] && continue
        lm_i=$((lm_i + 1))
        lm_warn=""
        [ -z "${mv_poster:-}" ] && lm_warn="$lm_warn ⚠غلاف"
        [ -z "${mv_url:-}" ]    && lm_warn="$lm_warn ⚠رابط"
        [ -z "${mv_story:-}" ]  && lm_warn="$lm_warn ⚠قصة"
        printf '  %b[%d]%b %s (%s) — %s — ★%s' \
            "$CYN" "$lm_i" "$R" "$mv_title" "${mv_year:-?}" "${mv_genre:-?}" "${mv_rating:-?}"
        [ -n "$lm_warn" ] && printf '  %b%s%b' "$YEL" "$lm_warn" "$R"
        printf '\n'
    done < "$DB_MOVIES"
}

list_channels() {
    if [ ! -s "$DB_CHANNELS" ]; then
        printf '  %b(لا توجد قنوات بعد)%b\n' "$DIM" "$R"
        return
    fi
    lc_i=0
    while IFS="$US" read -r ch_name ch_poster ch_stream ch_desc; do
        [ -z "${ch_name:-}" ] && continue
        lc_i=$((lc_i + 1))
        lc_warn=""
        [ -z "${ch_poster:-}" ] && lc_warn="$lc_warn ⚠غلاف"
        [ -z "${ch_stream:-}" ] && lc_warn="$lc_warn ⚠بث"
        printf '  %b[%d]%b %s — %s' \
            "$CYN" "$lc_i" "$R" "$ch_name" "${ch_desc:-}"
        [ -n "$lc_warn" ] && printf '  %b%s%b' "$YEL" "$lc_warn" "$R"
        printf '\n'
    done < "$DB_CHANNELS"
}

# ═══════════════════════════════════════════════════════════════════════════
#  الأفلام
# ═══════════════════════════════════════════════════════════════════════════
add_movie() {
    clear_screen
    printf '%b═══ ➕ إضافة فيلم جديد ═══%b\n\n' "$MAG$BOLD" "$R"

    am_title=""
    while [ -z "$am_title" ]; do
        ask "عنوان الفيلم" ""
        am_title="$ASK_RESULT"
        [ -z "$am_title" ] && printf '  %bالعنوان مطلوب!%b\n' "$RED" "$R"
    done

    am_def_year=$(date +%Y 2>/dev/null || echo 2025)
    ask "سنة الإنتاج"     "$am_def_year"; am_year="$ASK_RESULT"
    ask "التصنيف"         "عام";          am_genre="$ASK_RESULT"
    ask "التقييم (0-10)"  "0";            am_rating="$ASK_RESULT"
    ask "رابط الغلاف"     "";             am_poster="$ASK_RESULT"

    am_url=""
    while [ -z "$am_url" ]; do
        ask "رابط المشاهدة (m3u8 / mp4 / iframe)" ""
        am_url="$ASK_RESULT"
        [ -z "$am_url" ] && printf '  %bالرابط مطلوب!%b\n' "$RED" "$R"
    done

    ask "تسمية السيرفر"   "سيرفر رئيسي"; am_label="$ASK_RESULT"
    ask "القصة (اختياري)" "";             am_story="$ASK_RESULT"

    printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
        "$am_title" "$US" "$am_year" "$US" "$am_genre" "$US" "$am_rating" "$US" \
        "$am_poster" "$US" "$am_story" "$US" "$am_url" "$US" "$am_label" >> "$DB_MOVIES"

    save_all
    notify "✓ تمت الإضافة" "الفيلم: $am_title"
    git_push
}

edit_movie() {
    clear_screen
    printf '%b═══ ✏️  تعديل فيلم ═══%b\n' "$MAG$BOLD" "$R"
    list_movies
    printf '\n'
    printf '%bاختر رقم الفيلم (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r em_idx || em_idx=""
    { [ -z "$em_idx" ] || [ "$em_idx" = "0" ]; } && return 0
    case "$em_idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac

    em_line=1; em_found=0
    em_t=""; em_y=""; em_g=""; em_r=""; em_p=""; em_s=""; em_u=""; em_l=""
    while IFS="$US" read -r t y g r p s u l; do
        if [ "$em_line" -eq "$em_idx" ]; then
            em_t="${t:-}"; em_y="${y:-}"; em_g="${g:-}"; em_r="${r:-}"
            em_p="${p:-}"; em_s="${s:-}"; em_u="${u:-}"; em_l="${l:-}"
            em_found=1; break
        fi
        em_line=$((em_line + 1))
    done < "$DB_MOVIES"

    if [ "$em_found" -eq 0 ]; then notify "✗ خطأ" "رقم غير موجود"; return 1; fi

    printf '\n%bاترك الحقل فارغاً (Enter) للاحتفاظ — أو -- لتفريغه%b\n\n' "$DIM" "$R" "$DIM" "$R"

    ask "العنوان"        "$em_t"; em_nt="$ASK_RESULT"
    ask "السنة"          "$em_y"; em_ny="$ASK_RESULT"
    ask "التصنيف"        "$em_g"; em_ng="$ASK_RESULT"
    ask "التقييم"        "$em_r"; em_nr="$ASK_RESULT"
    ask "رابط الغلاف"    "$em_p"; em_np="$ASK_RESULT"
    ask "رابط المشاهدة"  "$em_u"; em_nu="$ASK_RESULT"
    ask "تسمية السيرفر"  "$em_l"; em_nl="$ASK_RESULT"
    ask "القصة"          "$em_s"; em_ns="$ASK_RESULT"

    awk -v target="$em_idx" \
        -v t="$em_nt" -v y="$em_ny" -v g="$em_ng" -v r="$em_nr" \
        -v p="$em_np" -v s="$em_ns" -v u="$em_nu" -v l="$em_nl" '
        BEGIN { US = sprintf("%c", 31) }
        NR == target { print t US y US g US r US p US s US u US l; next }
        { print }
    ' "$DB_MOVIES" > "$DB_MOVIES.tmp" && mv "$DB_MOVIES.tmp" "$DB_MOVIES"

    save_all
    notify "✓ تم التعديل" "الفيلم: $em_nt"
    git_push
}

delete_movie() {
    clear_screen
    printf '%b═══ 🗑 حذف فيلم ═══%b\n' "$RED$BOLD" "$R"
    list_movies
    printf '\n'
    printf '%bاختر رقم الفيلم للحذف (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r dm_idx || dm_idx=""
    { [ -z "$dm_idx" ] || [ "$dm_idx" = "0" ]; } && return 0
    case "$dm_idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac

    printf '%bمتأكد؟ (y/N)%b: ' "$YEL" "$R"
    IFS= read -r dm_c || dm_c=""
    case "$dm_c" in y|Y|yes|YES) :;; *) printf '%bتم الإلغاء.%b\n' "$DIM" "$R"; return 0;; esac

    dm_name=$(awk -v n="$dm_idx" -v US="$US" 'BEGIN{FS=US} NR==n{print $1; exit}' "$DB_MOVIES")
    awk -v target="$dm_idx" 'NR != target' "$DB_MOVIES" > "$DB_MOVIES.tmp" \
        && mv "$DB_MOVIES.tmp" "$DB_MOVIES"

    save_all
    notify "✓ تم الحذف" "الفيلم: $dm_name"
    git_push
}

# ═══════════════════════════════════════════════════════════════════════════
#  القنوات
# ═══════════════════════════════════════════════════════════════════════════
add_channel() {
    clear_screen
    printf '%b═══ ➕ إضافة قناة جديدة ═══%b\n\n' "$MAG$BOLD" "$R"

    ac_name=""
    while [ -z "$ac_name" ]; do
        ask "اسم القناة" ""
        ac_name="$ASK_RESULT"
        [ -z "$ac_name" ] && printf '  %bالاسم مطلوب!%b\n' "$RED" "$R"
    done
    ask "رابط غلاف القناة" ""; ac_poster="$ASK_RESULT"

    ac_stream=""
    while [ -z "$ac_stream" ]; do
        ask "رابط البث المباشر (m3u8 / ts)" ""
        ac_stream="$ASK_RESULT"
        [ -z "$ac_stream" ] && printf '  %bرابط البث مطلوب!%b\n' "$RED" "$R"
    done
    ask "وصف القناة" "قناة $ac_name — بث مباشر"; ac_desc="$ASK_RESULT"

    printf '%s%s%s%s%s%s%s\n' \
        "$ac_name" "$US" "$ac_poster" "$US" "$ac_stream" "$US" "$ac_desc" >> "$DB_CHANNELS"

    save_all
    notify "✓ تمت الإضافة" "القناة: $ac_name"
    git_push
}

edit_channel() {
    clear_screen
    printf '%b═══ ✏️  تعديل قناة ═══%b\n' "$MAG$BOLD" "$R"
    list_channels
    printf '\n'
    printf '%bاختر رقم القناة (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r ec_idx || ec_idx=""
    { [ -z "$ec_idx" ] || [ "$ec_idx" = "0" ]; } && return 0
    case "$ec_idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac

    ec_line=1; ec_found=0
    ec_n=""; ec_p=""; ec_s=""; ec_d=""
    while IFS="$US" read -r n p s d; do
        if [ "$ec_line" -eq "$ec_idx" ]; then
            ec_n="${n:-}"; ec_p="${p:-}"; ec_s="${s:-}"; ec_d="${d:-}"
            ec_found=1; break
        fi
        ec_line=$((ec_line + 1))
    done < "$DB_CHANNELS"

    if [ "$ec_found" -eq 0 ]; then notify "✗ خطأ" "رقم غير موجود"; return 1; fi

    printf '\n%bاترك الحقل فارغاً (Enter) للاحتفاظ — أو -- لتفريغه%b\n\n' "$DIM" "$R" "$DIM" "$R"

    ask "اسم القناة"    "$ec_n"; ec_nn="$ASK_RESULT"
    ask "رابط الغلاف"   "$ec_p"; ec_np="$ASK_RESULT"
    ask "رابط البث"     "$ec_s"; ec_ns="$ASK_RESULT"
    ask "الوصف"         "$ec_d"; ec_nd="$ASK_RESULT"

    awk -v target="$ec_idx" -v n="$ec_nn" -v p="$ec_np" -v s="$ec_ns" -v d="$ec_nd" '
        BEGIN { US = sprintf("%c", 31) }
        NR == target { print n US p US s US d; next }
        { print }
    ' "$DB_CHANNELS" > "$DB_CHANNELS.tmp" && mv "$DB_CHANNELS.tmp" "$DB_CHANNELS"

    save_all
    notify "✓ تم التعديل" "القناة: $ec_nn"
    git_push
}

delete_channel() {
    clear_screen
    printf '%b═══ 🗑 حذف قناة ═══%b\n' "$RED$BOLD" "$R"
    list_channels
    printf '\n'
    printf '%bاختر رقم القناة للحذف (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r dc_idx || dc_idx=""
    { [ -z "$dc_idx" ] || [ "$dc_idx" = "0" ]; } && return 0
    case "$dc_idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac

    printf '%bمتأكد؟ (y/N)%b: ' "$YEL" "$R"
    IFS= read -r dc_c || dc_c=""
    case "$dc_c" in y|Y|yes|YES) :;; *) printf '%bتم الإلغاء.%b\n' "$DIM" "$R"; return 0;; esac

    dc_name=$(awk -v n="$dc_idx" -v US="$US" 'BEGIN{FS=US} NR==n{print $1; exit}' "$DB_CHANNELS")
    awk -v target="$dc_idx" 'NR != target' "$DB_CHANNELS" > "$DB_CHANNELS.tmp" \
        && mv "$DB_CHANNELS.tmp" "$DB_CHANNELS"

    save_all
    notify "✓ تم الحذف" "القناة: $dc_name"
    git_push
}

# ═══════════════════════════════════════════════════════════════════════════
#  الترحيل من JSON القديم
# ═══════════════════════════════════════════════════════════════════════════
migrate_movies() {
    [ ! -f "$JSON_MOVIES" ] && return 1
    awk '
    BEGIN { US = sprintf("%c", 31); in_m=0; title=""; year="0"; genre="عام"; rating="0"; poster=""; story=""; url=""; label="سيرفر رئيسي" }
    /^    \{$/ {
        in_m=1
        title=""; year="0"; genre="عام"; rating="0"; poster=""; story=""; url=""; label="سيرفر رئيسي"
        next
    }
    in_m && /^    \},?$/ {
        if (title != "") print title US year US genre US rating US poster US story US url US label
        in_m=0; next
    }
    in_m && /"title":/  { v=$0; sub(/.*"title": *"/,  "", v); sub(/".*/, "", v); title=v }
    in_m && /"year":/   { v=$0; sub(/.*"year": */,   "", v); sub(/[,"].*/, "", v); year=v }
    in_m && /"genre":/  { v=$0; sub(/.*"genre": *"/,  "", v); sub(/".*/, "", v); genre=v }
    in_m && /"rating":/ { v=$0; sub(/.*"rating": */, "", v); sub(/[,"].*/, "", v); rating=v }
    in_m && /"poster":/ { v=$0; sub(/.*"poster": *"/, "", v); sub(/".*/, "", v); poster=v }
    in_m && /"story":/  { v=$0; sub(/.*"story": *"/,  "", v); sub(/".*/, "", v); story=v }
    in_m && /"label":/  { v=$0; sub(/.*"label": *"/,  "", v); sub(/".*/, "", v); label=v }
    in_m && /"url":/    { v=$0; sub(/.*"url": *"/,    "", v); sub(/".*/, "", v); url=v }
    ' "$JSON_MOVIES" > "$DB_MOVIES"
    return 0
}

migrate_channels() {
    [ ! -f "$JSON_CHANNELS" ] && return 1
    awk '
    BEGIN { US = sprintf("%c", 31); in_c=0; name=""; poster=""; stream=""; desc="" }
    /^    \{$/ {
        in_c=1
        name=""; poster=""; stream=""; desc=""
        next
    }
    in_c && /^    \},?$/ {
        if (name != "") print name US poster US stream US desc
        in_c=0; next
    }
    in_c && /"name":/   { v=$0; sub(/.*"name": *"/,   "", v); sub(/".*/, "", v); name=v }
    in_c && /"poster":/ { v=$0; sub(/.*"poster": *"/, "", v); sub(/".*/, "", v); poster=v }
    in_c && /"stream":/ { v=$0; sub(/.*"stream": *"/, "", v); sub(/".*/, "", v); stream=v }
    in_c && /"desc":/   { v=$0; sub(/.*"desc": *"/,   "", v); sub(/".*/, "", v); desc=v }
    ' "$JSON_CHANNELS" > "$DB_CHANNELS"
    return 0
}

# ─────────────────── الإعداد الأولي ───────────────────
first_run_setup() {
    # الترحيل من JSON إن وُجد ولم يوجد DB
    if [ ! -f "$DB_MOVIES" ] && [ -f "$JSON_MOVIES" ]; then
        printf '\n%bتم العثور على movies.json — هل تريد استيراد الأفلام؟ (y/N)%b: ' "$YEL" "$R"
        IFS= read -r m_ans || m_ans=""
        case "$m_ans" in
            y|Y|yes|YES)
                migrate_movies
                m_count=$(wc -l < "$DB_MOVIES" 2>/dev/null | tr -d ' ' || echo 0)
                notify "✓ استيراد" "تم استيراد $m_count فيلم"
                ;;
            *) : > "$DB_MOVIES" ;;
        esac
    fi
    if [ ! -f "$DB_CHANNELS" ] && [ -f "$JSON_CHANNELS" ]; then
        printf '\n%bتم العثور على channels.json — هل تريد استيراد القنوات؟ (y/N)%b: ' "$YEL" "$R"
        IFS= read -r c_ans || c_ans=""
        case "$c_ans" in
            y|Y|yes|YES)
                migrate_channels
                c_count=$(wc -l < "$DB_CHANNELS" 2>/dev/null | tr -d ' ' || echo 0)
                notify "✓ استيراد" "تم استيراد $c_count قناة"
                ;;
            *) : > "$DB_CHANNELS" ;;
        esac
    fi
    # إنشاء DB فارغة إن لم توجد
    [ -f "$DB_MOVIES" ]   || : > "$DB_MOVIES"
    [ -f "$DB_CHANNELS" ] || : > "$DB_CHANNELS"

    # إعداد git إن لم يوجد
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf '\n%b⚠ لم يتم اكتشاف مستودع git%b\n' "$YEL" "$R"
        printf 'هل تريد تهيئة Git الآن؟ (y/N): '
        IFS= read -r g_ans || g_ans=""
        case "$g_ans" in
            y|Y|yes|YES)
                git init >/dev/null 2>&1
                printf 'رابط المستودع (git@github.com:user/repo.git أو https://...): '
                IFS= read -r g_url || g_url=""
                if [ -n "$g_url" ]; then
                    git remote add origin "$g_url" 2>/dev/null
                    printf '%b✓ تم ربط المستودع%b\n' "$GRN" "$R"
                fi
                ;;
        esac
    fi
    # .gitignore بسيط
    if [ -d ".git" ] && [ ! -f ".gitignore" ]; then
        printf '.DS_Store\n*.tmp\n*.log\n' > .gitignore
    fi
}

# ─────────────────── القائمة الرئيسية ───────────────────
show_menu() {
    clear_screen
    printf '%b╔══════════════════════════════════════════╗%b\n' "$CYN" "$R"
    printf '%b║%b  %b🎬 سينمانا — لوحة التحكم  v%s%b          %b║%b\n' "$CYN" "$R" "$MAG$BOLD" "$VERSION" "$R" "$CYN" "$R"
    printf '%b║%b  %b© 2025 B6_7E | بيكاس%b               %b║%b\n' "$CYN" "$R" "$DIM" "$R" "$CYN" "$R"
    printf '%b╚══════════════════════════════════════════╝%b\n' "$CYN" "$R"

    mc=0; cc=0
    [ -s "$DB_MOVIES" ]   && mc=$(wc -l < "$DB_MOVIES"   | tr -d ' ')
    [ -s "$DB_CHANNELS" ] && cc=$(wc -l < "$DB_CHANNELS" | tr -d ' ')
    printf '  الأفلام: %b%s%b   |   القنوات: %b%s%b\n\n' "$GRN" "$mc" "$R" "$GRN" "$cc" "$R"

    printf '  %b[1]%b 📽  عرض الأفلام\n'        "$WHT" "$R"
    printf '  %b[2]%b ➕  إضافة فيلم\n'          "$WHT" "$R"
    printf '  %b[3]%b ✏️   تعديل فيلم\n'         "$WHT" "$R"
    printf '  %b[4]%b 🗑  حذف فيلم\n'           "$WHT" "$R"
    printf '  %b────────────────────────────────%b\n' "$DIM" "$R"
    printf '  %b[5]%b 📺  عرض القنوات\n'         "$WHT" "$R"
    printf '  %b[6]%b ➕  إضافة قناة\n'          "$WHT" "$R"
    printf '  %b[7]%b ✏️   تعديل قناة\n'         "$WHT" "$R"
    printf '  %b[8]%b 🗑  حذف قناة\n'           "$WHT" "$R"
    printf '  %b────────────────────────────────%b\n' "$DIM" "$R"
    printf '  %b[9]%b 🚀  رفع إلى GitHub الآن\n' "$WHT" "$R"
    printf '  %b[0]%b 🚪  خروج\n'               "$WHT" "$R"
    printf '%b══════════════════════════════════════════%b\n' "$CYN" "$R"
    printf '%b▸ اختيارك: %b' "$GRN" "$R"
}

# ─────────────────── نقطة البداية ───────────────────
trap 'printf "\n%bوداعاً 👋%b\n" "$CYN" "$R"; exit 0' INT TERM

# إظهار الحقوق عند الإقلاع
printf '%b\n🎬 سينمانا — لوحة التحكم v%s\n%b%s%b\n\n' "$MAG$BOLD" "$VERSION" "$DIM" "$COPYRIGHT" "$R"
sleep 0.8

first_run_setup

while true; do
    show_menu
    MENU_CHOICE=""
    IFS= read -r MENU_CHOICE || exit 0
    printf '\n'
    case "$MENU_CHOICE" in
        1) list_movies;    pause_enter ;;
        2) add_movie;      pause_enter ;;
        3) edit_movie;     pause_enter ;;
        4) delete_movie;   pause_enter ;;
        5) list_channels;  pause_enter ;;
        6) add_channel;    pause_enter ;;
        7) edit_channel;   pause_enter ;;
        8) delete_channel; pause_enter ;;
        9) save_all; git_push; pause_enter ;;
        0) printf '%bوداعاً 👋%b\n' "$CYN" "$R"; exit 0 ;;
        *) printf '%bاختيار غير صالح.%b\n' "$RED" "$R"; sleep 1 ;;
    esac
done