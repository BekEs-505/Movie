#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
#  Movie BekEs — لوحة التحكم v5.0
#  © 2025 B6_7E | بيكاس — جميع الحقوق محفوظة
#  يعمل على: NewTerm iOS · Termux · Linux · macOS — بدون Python
# ═══════════════════════════════════════════════════════════════════════
set -u
VERSION="5.0"
COPYRIGHT="© 2025 B6_7E | بيكاس — جميع الحقوق محفوظة"
GIT_MSG="Init"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR" 2>/dev/null || { printf 'تعذر الدخول إلى مجلد المشروع\n'; exit 1; }

DATA_DIR="data"
DB_MOVIES="$DATA_DIR/movies.db"
DB_CHANNELS="$DATA_DIR/channels.db"
JSON_MOVIES="$DATA_DIR/movies.json"
JSON_CHANNELS="$DATA_DIR/channels.json"
CONTENT_JS="$DATA_DIR/content.js"
US=$(printf '\037')
mkdir -p "$DATA_DIR" 2>/dev/null
[ -f "$DB_MOVIES" ]   || : > "$DB_MOVIES"
[ -f "$DB_CHANNELS" ] || : > "$DB_CHANNELS"

# ─── ألوان ───
R='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
RED='\033[31m'; GRN='\033[32m'; YEL='\033[33m'
BLU='\033[34m'; MAG='\033[35m'; CYN='\033[36m'; WHT='\033[37m'

clr(){ command -v clear >/dev/null 2>&1 && clear 2>/dev/null || printf '\033[2J\033[H'; }

# ─── إشعار ───
notify(){
    printf '\a'
    printf '\033]0;%s\007' "$1"
    printf '\n%b╭────────────────────────────────────╮%b\n' "$CYN" "$R"
    printf '%b│%b %b🔔 %s%b\n' "$CYN" "$R" "$BOLD" "$1" "$R"
    printf '%b│%b %s\n'        "$CYN" "$R" "$2"
    printf '%b╰────────────────────────────────────╯%b\n' "$CYN" "$R"
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1 &
    fi
}

# ─── أدوات ───
jesc(){ printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

# ─── توليد JSON + content.js ───
save_movies_json(){
    first=1
    {
        printf '{\n  "movies": [\n'
        if [ -s "$DB_MOVIES" ]; then
            while IFS="$US" read -r t y g r p s u l; do
                [ -z "${t:-}" ] && continue
                [ "$first" -eq 0 ] && printf '    },\n'
                first=0
                printf '    {\n      "title": "%s",\n      "year": %s,\n      "genre": "%s",\n      "rating": %s,\n      "poster": "%s",\n      "story": "%s",\n      "sources": [\n        {\n          "label": "%s",\n          "url": "%s"\n        }\n      ]' \
                    "$(jesc "$t")" "${y:-0}" "$(jesc "${g:-عام}")" "${r:-0}" \
                    "$(jesc "${p:-}")" "$(jesc "${s:-}")" "$(jesc "${l:-سيرفر رئيسي}")" "$(jesc "${u:-}")"
            done < "$DB_MOVIES"
        fi
        [ "$first" -eq 0 ] && printf '\n    }\n'
        printf '  ]\n}\n'
    } > "$JSON_MOVIES"
}
save_channels_json(){
    first=1
    {
        printf '{\n  "channels": [\n'
        if [ -s "$DB_CHANNELS" ]; then
            while IFS="$US" read -r n p s d; do
                [ -z "${n:-}" ] && continue
                [ "$first" -eq 0 ] && printf '    },\n'
                first=0
                printf '    {\n      "name": "%s",\n      "poster": "%s",\n      "stream": "%s",\n      "desc": "%s",\n      "sources": [\n        {\n          "label": "سيرفر مباشر",\n          "url": "%s"\n        }\n      ]' \
                    "$(jesc "$n")" "$(jesc "${p:-}")" "$(jesc "${s:-}")" \
                    "$(jesc "${d:-}")" "$(jesc "${s:-}")"
            done < "$DB_CHANNELS"
        fi
        [ "$first" -eq 0 ] && printf '\n    }\n'
        printf '  ]\n}\n'
    } > "$JSON_CHANNELS"
}
save_content_js(){
    {
        printf '/* Movie BekEs — %s */\n' "$COPYRIGHT"
        printf 'window.__CINEMA_DATA__ = {\n  "movies": ['
        f=1
        if [ -s "$DB_MOVIES" ]; then
            while IFS="$US" read -r t y g r p s u l; do
                [ -z "${t:-}" ] && continue
                [ "$f" -eq 0 ] && printf ','
                f=0
                printf '\n    {"title":"%s","year":%s,"genre":"%s","rating":%s,"poster":"%s","story":"%s","sources":[{"label":"%s","url":"%s"}]}' \
                    "$(jesc "$t")" "${y:-0}" "$(jesc "${g:-عام}")" "${r:-0}" \
                    "$(jesc "${p:-}")" "$(jesc "${s:-}")" \
                    "$(jesc "${l:-سيرفر رئيسي}")" "$(jesc "${u:-}")"
            done < "$DB_MOVIES"
        fi
        printf '\n  ],\n  "channels": ['
        f=1
        if [ -s "$DB_CHANNELS" ]; then
            while IFS="$US" read -r n p s d; do
                [ -z "${n:-}" ] && continue
                [ "$f" -eq 0 ] && printf ','
                f=0
                printf '\n    {"name":"%s","poster":"%s","stream":"%s","desc":"%s","sources":[{"label":"سيرفر مباشر","url":"%s"}]}' \
                    "$(jesc "$n")" "$(jesc "${p:-}")" "$(jesc "${s:-}")" \
                    "$(jesc "${d:-}")" "$(jesc "${s:-}")"
            done < "$DB_CHANNELS"
        fi
        printf '\n  ]\n};\n'
    } > "$CONTENT_JS"
}
save_all(){ save_movies_json; save_channels_json; save_content_js; }

# ════════ Git Push مع مصادقة ════════
# متغيرات الجلسة (تُحفظ أثناء التشغيل فقط)
GIT_USER="${GIT_USER:-}"
GIT_PASS="${GIT_PASS:-}"

_do_git_push(){
    # يحاول الرفع. يعيد 0 نجاح، 1 فشل مصادقة، 2 فشل آخر
    tmp=$(mktemp 2>/dev/null || echo "/tmp/gitpush.$$")
    if git push >"$tmp" 2>&1; then rm -f "$tmp"; return 0; fi
    if grep -qiE 'authentication|permission denied|403|could not read username|terminal prompts disabled' "$tmp"; then
        rm -f "$tmp"; return 1
    fi
    cp "$tmp" /tmp/cp_last_err 2>/dev/null
    rm -f "$tmp"; return 2
}

_prompt_credentials(){
    printf '\n%b🔑 مطلوب مصادقة GitHub%b\n' "$YEL" "$R"
    printf '%b(استخدم Personal Access Token بدل كلمة المرور)%b\n' "$DIM" "$R"
    printf 'اسم المستخدم: '; IFS= read -r GIT_USER || GIT_USER=""
    printf 'كلمة المرور / التوكن: '; IFS= read -r GIT_PASS || GIT_PASS=""
    [ -z "$GIT_USER" ] || [ -z "$GIT_PASS" ] && return 1
    return 0
}

git_push(){
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        notify "⚠ Git" "ليس مستودع git — تخطي الرفع"
        printf '%b  لتفعيله:%b\n  git init && git remote add origin <URL>\n' "$DIM" "$R"
        return 1
    fi

    git add --all >/dev/null 2>&1

    # ⭐ رفع دائماً حتى بدون تغييرات
    git commit --allow-empty -m "$GIT_MSG" >/dev/null 2>&1

    # محاولة الرفع
    _do_git_push; rc=$?
    [ "$rc" -eq 0 ] && { notify "✓ GitHub" "تم الرفع بنجاح"; return 0; }

    # فشل مصادقة — اطلب التوكن
    if [ "$rc" -eq 1 ]; then
        if _prompt_credentials; then
            REPO_URL=$(git remote get-url origin 2>/dev/null)
            [ -z "$REPO_URL" ] && { notify "✗ GitHub" "لا يوجد origin"; return 1; }
            # تحويل SSH إلى HTTPS إن لزم
            case "$REPO_URL" in
                git@*) REPO_URL=$(printf '%s' "$REPO_URL" | sed -E 's#git@([^:]+):([^/]+)/(.+)#https://\1/\2/\3#') ;;
            esac
            # حقن المصادقة
            AUTH_URL=$(printf '%s' "$REPO_URL" | sed -E "s#^https://#https://${GIT_USER}:${GIT_PASS}@#")
            if git push "$AUTH_URL" >/tmp/cp_git.$$ 2>&1; then
                rm -f /tmp/cp_git.$$
                notify "✓ GitHub" "تم الرفع بعد المصادقة"
                return 0
            fi
            notify "✗ GitHub" "فشلت المصادقة — تحقق من التوكن"
            tail -5 /tmp/cp_git.$$ 2>/dev/null | sed 's/^/  /'
            rm -f /tmp/cp_git.$$
            return 1
        else
            notify "✗ GitHub" "لم يتم إدخال بيانات — أُلغي الرفع"
            return 1
        fi
    fi

    # فشل آخر
    notify "✗ GitHub" "فشل الرفع — تحقق من الاتصال"
    tail -5 /tmp/cp_last_err 2>/dev/null | sed 's/^/  /'
    rm -f /tmp/cp_last_err
    return 1
}

# ─── إدخال ───
ask(){
    if [ -n "$2" ]; then
        printf '%b%s%b %b[%s]%b: ' "$WHT" "$1" "$R" "$DIM" "$2" "$R"
    else
        printf '%b%s%b: ' "$WHT" "$1" "$R"
    fi
    IFS= read -r ans || ans=""
    if [ "$ans" = "--" ]; then ans=""
    elif [ -z "$ans" ] && [ -n "$2" ]; then ans="$2"
    fi
    ASK_RESULT="$ans"
}
pause_enter(){ printf '\n%bاضغط Enter للمتابعة...%b' "$DIM" "$R"; IFS= read -r _ || true; }

# ─── عرض ───
list_movies(){
    if [ ! -s "$DB_MOVIES" ]; then printf '  %b(لا توجد أفلام)%b\n' "$DIM" "$R"; return; fi
    i=0
    while IFS="$US" read -r t y g r p s u l; do
        [ -z "${t:-}" ] && continue
        i=$((i+1)); w=""
        [ -z "${p:-}" ] && w="$w ⚠غلاف"
        [ -z "${u:-}" ] && w="$w ⚠رابط"
        printf '  %b[%d]%b %s (%s) — %s — ★%s%b%s%b\n' \
            "$CYN" "$i" "$R" "$t" "${y:-?}" "${g:-?}" "${r:-?}" "$YEL" "$w" "$R"
    done < "$DB_MOVIES"
}
list_channels(){
    if [ ! -s "$DB_CHANNELS" ]; then printf '  %b(لا توجد قنوات)%b\n' "$DIM" "$R"; return; fi
    i=0
    while IFS="$US" read -r n p s d; do
        [ -z "${n:-}" ] && continue
        i=$((i+1)); w=""
        [ -z "${p:-}" ] && w="$w ⚠غلاف"
        [ -z "${s:-}" ] && w="$w ⚠بث"
        printf '  %b[%d]%b %s — %s%b%s%b\n' "$CYN" "$i" "$R" "$n" "${d:-}" "$YEL" "$w" "$R"
    done < "$DB_CHANNELS"
}

# ═══════ الأفلام ═══════
add_movie(){
    clr; printf '%b═══ ➕ إضافة فيلم ═══%b\n\n' "$MAG$BOLD" "$R"
    am_t=""
    while [ -z "$am_t" ]; do
        ask "عنوان الفيلم" ""; am_t="$ASK_RESULT"
        [ -z "$am_t" ] && printf '  %bمطلوب!%b\n' "$RED" "$R"
    done
    ask "السنة" "$(date +%Y 2>/dev/null || echo 2025)"; am_y="$ASK_RESULT"
    ask "التصنيف" "عام"; am_g="$ASK_RESULT"
    ask "التقييم (0-10)" "0"; am_r="$ASK_RESULT"
    ask "رابط الغلاف" ""; am_p="$ASK_RESULT"
    am_u=""
    while [ -z "$am_u" ]; do
        ask "رابط المشاهدة" ""; am_u="$ASK_RESULT"
        [ -z "$am_u" ] && printf '  %bمطلوب!%b\n' "$RED" "$R"
    done
    ask "تسمية السيرفر" "سيرفر رئيسي"; am_l="$ASK_RESULT"
    ask "القصة (اختياري)" ""; am_s="$ASK_RESULT"

    printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
        "$am_t" "$US" "$am_y" "$US" "$am_g" "$US" "$am_r" "$US" \
        "$am_p" "$US" "$am_s" "$US" "$am_u" "$US" "$am_l" >> "$DB_MOVIES"

    save_all; notify "✓ تمت الإضافة" "الفيلم: $am_t"; git_push
}

edit_movie(){
    clr; printf '%b═══ ✏️  تعديل فيلم ═══%b\n' "$MAG$BOLD" "$R"; list_movies; printf '\n'
    printf '%bرقم الفيلم (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac

    # جلب السجل الحالي
    ln=1; found=0
    et=""; ey=""; eg=""; er=""; ep=""; es=""; eu=""; el=""
    while IFS="$US" read -r t y g r p s u l; do
        if [ "$ln" -eq "$idx" ]; then
            et="$t"; ey="$y"; eg="$g"; er="$r"; ep="$p"; es="$s"; eu="$u"; el="$l"
            found=1; break
        fi
        ln=$((ln+1))
    done < "$DB_MOVIES"
    [ "$found" -eq 0 ] && { notify "✗ خطأ" "رقم غير موجود"; return 1; }

    printf '\n%bاترك فارغاً = احتفاظ — أو -- = تفريغ%b\n\n' "$DIM" "$R"
    ask "العنوان" "$et"; nt="$ASK_RESULT"
    ask "السنة" "$ey"; ny="$ASK_RESULT"
    ask "التصنيف" "$eg"; ng="$ASK_RESULT"
    ask "التقييم" "$er"; nr="$ASK_RESULT"
    ask "رابط الغلاف" "$ep"; np="$ASK_RESULT"
    ask "رابط المشاهدة" "$eu"; nu="$ASK_RESULT"
    ask "تسمية السيرفر" "$el"; nl="$ASK_RESULT"
    ask "القصة" "$es"; ns="$ASK_RESULT"

    awk -v target="$idx" -v t="$nt" -v y="$ny" -v g="$ng" -v r="$nr" \
        -v p="$np" -v s="$ns" -v u="$nu" -v l="$nl" '
        BEGIN { US = sprintf("%c",31) }
        NR==target { print t US y US g US r US p US s US u US l; next }
        { print }' "$DB_MOVIES" > "$DB_MOVIES.tmp" && mv "$DB_MOVIES.tmp" "$DB_MOVIES"

    save_all; notify "✓ تم التعديل" "الفيلم: $nt"; git_push
}

delete_movie(){
    clr; printf '%b═══ 🗑 حذف فيلم ═══%b\n' "$RED$BOLD" "$R"; list_movies; printf '\n'
    printf '%bرقم الفيلم (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac
    printf '%bمتأكد؟ (y/N)%b: ' "$YEL" "$R"
    IFS= read -r c || c=""
    case "$c" in y|Y|yes|YES) :;; *) printf '%bأُلغي.%b\n' "$DIM" "$R"; return 0;; esac
    name=$(awk -v n="$idx" -v US="$US" 'BEGIN{FS=US} NR==n{print $1; exit}' "$DB_MOVIES")
    awk -v target="$idx" 'NR!=target' "$DB_MOVIES" > "$DB_MOVIES.tmp" && mv "$DB_MOVIES.tmp" "$DB_MOVIES"
    save_all; notify "✓ تم الحذف" "الفيلم: $name"; git_push
}

# ═══════ القنوات ═══════
add_channel(){
    clr; printf '%b═══ ➕ إضافة قناة ═══%b\n\n' "$MAG$BOLD" "$R"
    ac_n=""
    while [ -z "$ac_n" ]; do
        ask "اسم القناة" ""; ac_n="$ASK_RESULT"
        [ -z "$ac_n" ] && printf '  %bمطلوب!%b\n' "$RED" "$R"
    done
    ask "رابط غلاف القناة" ""; ac_p="$ASK_RESULT"
    ac_s=""
    while [ -z "$ac_s" ]; do
        ask "رابط البث المباشر" ""; ac_s="$ASK_RESULT"
        [ -z "$ac_s" ] && printf '  %bمطلوب!%b\n' "$RED" "$R"
    done
    ask "الوصف" "قناة $ac_n — بث مباشر"; ac_d="$ASK_RESULT"

    printf '%s%s%s%s%s%s%s\n' "$ac_n" "$US" "$ac_p" "$US" "$ac_s" "$US" "$ac_d" >> "$DB_CHANNELS"
    save_all; notify "✓ تمت الإضافة" "القناة: $ac_n"; git_push
}

edit_channel(){
    clr; printf '%b═══ ✏️  تعديل قناة ═══%b\n' "$MAG$BOLD" "$R"; list_channels; printf '\n'
    printf '%bرقم القناة (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac

    ln=1; found=0; en=""; ep=""; es=""; ed=""
    while IFS="$US" read -r n p s d; do
        if [ "$ln" -eq "$idx" ]; then en="$n"; ep="$p"; es="$s"; ed="$d"; found=1; break; fi
        ln=$((ln+1))
    done < "$DB_CHANNELS"
    [ "$found" -eq 0 ] && { notify "✗ خطأ" "رقم غير موجود"; return 1; }

    printf '\n%bاترك فارغاً = احتفاظ — أو -- = تفريغ%b\n\n' "$DIM" "$R"
    ask "الاسم" "$en"; nn="$ASK_RESULT"
    ask "رابط الغلاف" "$ep"; np="$ASK_RESULT"
    ask "رابط البث" "$es"; ns="$ASK_RESULT"
    ask "الوصف" "$ed"; nd="$ASK_RESULT"

    awk -v target="$idx" -v n="$nn" -v p="$np" -v s="$ns" -v d="$nd" '
        BEGIN { US = sprintf("%c",31) }
        NR==target { print n US p US s US d; next }
        { print }' "$DB_CHANNELS" > "$DB_CHANNELS.tmp" && mv "$DB_CHANNELS.tmp" "$DB_CHANNELS"

    save_all; notify "✓ تم التعديل" "القناة: $nn"; git_push
}

delete_channel(){
    clr; printf '%b═══ 🗑 حذف قناة ═══%b\n' "$RED$BOLD" "$R"; list_channels; printf '\n'
    printf '%bرقم القناة (0=إلغاء)%b: ' "$WHT" "$R"
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "✗ خطأ" "رقم غير صالح"; return 1;; esac
    printf '%bمتأكد؟ (y/N)%b: ' "$YEL" "$R"
    IFS= read -r c || c=""
    case "$c" in y|Y|yes|YES) :;; *) printf '%bأُلغي.%b\n' "$DIM" "$R"; return 0;; esac
    name=$(awk -v n="$idx" -v US="$US" 'BEGIN{FS=US} NR==n{print $1; exit}' "$DB_CHANNELS")
    awk -v target="$idx" 'NR!=target' "$DB_CHANNELS" > "$DB_CHANNELS.tmp" && mv "$DB_CHANNELS.tmp" "$DB_CHANNELS"
    save_all; notify "✓ تم الحذف" "القناة: $name"; git_push
}

# ═══════ الترحيل من JSON القديم ═══════
first_run(){
    if [ ! -s "$DB_MOVIES" ] && [ -f "$JSON_MOVIES" ]; then
        printf '%bتم العثور على movies.json — استيراد؟ (y/N)%b: ' "$YEL" "$R"
        IFS= read -r a || a=""
        case "$a" in y|Y) 
            awk 'BEGIN{US=sprintf("%c",31);inm=0;t="";y="0";g="عام";r="0";p="";s="";u="";l="سيرفر رئيسي"}
            /^    \{$/{inm=1;t="";y="0";g="عام";r="0";p="";s="";u="";l="سيرفر رئيسي";next}
            inm&&/^    \},?$/{if(t!="")print t US y US g US r US p US s US u US l;inm=0;next}
            inm&&/"title":/{v=$0;sub(/.*"title": *"/,"",v);sub(/".*/,"",v);t=v}
            inm&&/"year":/{v=$0;sub(/.*"year": */,"",v);sub(/[,"].*/,"",v);y=v}
            inm&&/"genre":/{v=$0;sub(/.*"genre": *"/,"",v);sub(/".*/,"",v);g=v}
            inm&&/"rating":/{v=$0;sub(/.*"rating": */,"",v);sub(/[,"].*/,"",v);r=v}
            inm&&/"poster":/{v=$0;sub(/.*"poster": *"/,"",v);sub(/".*/,"",v);p=v}
            inm&&/"story":/{v=$0;sub(/.*"story": *"/,"",v);sub(/".*/,"",v);s=v}
            inm&&/"label":/{v=$0;sub(/.*"label": *"/,"",v);sub(/".*/,"",v);l=v}
            inm&&/"url":/{v=$0;sub(/.*"url": *"/,"",v);sub(/".*/,"",v);u=v}' \
            "$JSON_MOVIES" > "$DB_MOVIES"
            notify "✓ استيراد" "$(wc -l < "$DB_MOVIES" | tr -d ' ') فيلم" ;;
        esac
    fi
    if [ ! -s "$DB_CHANNELS" ] && [ -f "$JSON_CHANNELS" ]; then
        printf '%bتم العثور على channels.json — استيراد؟ (y/N)%b: ' "$YEL" "$R"
        IFS= read -r a || a=""
        case "$a" in y|Y)
            awk 'BEGIN{US=sprintf("%c",31);inc=0;n="";p="";s="";d=""}
            /^    \{$/{inc=1;n="";p="";s="";d="";next}
            inc&&/^    \},?$/{if(n!="")print n US p US s US d;inc=0;next}
            inc&&/"name":/{v=$0;sub(/.*"name": *"/,"",v);sub(/".*/,"",v);n=v}
            inc&&/"poster":/{v=$0;sub(/.*"poster": *"/,"",v);sub(/".*/,"",v);p=v}
            inc&&/"stream":/{v=$0;sub(/.*"stream": *"/,"",v);sub(/".*/,"",v);s=v}
            inc&&/"desc":/{v=$0;sub(/.*"desc": *"/,"",v);sub(/".*/,"",v);d=v}' \
            "$JSON_CHANNELS" > "$DB_CHANNELS"
            notify "✓ استيراد" "$(wc -l < "$DB_CHANNELS" | tr -d ' ') قناة" ;;
        esac
    fi
    # إعداد git إن لم يوجد
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf '\n%b⚠ لا يوجد مستودع git%b — تهيئة الآن؟ (y/N): ' "$YEL" "$R"
        IFS= read -r a || a=""
        case "$a" in y|Y)
            git init >/dev/null 2>&1
            printf 'رابط المستودع (https://github.com/user/repo.git): '
            IFS= read -r url || url=""
            [ -n "$url" ] && git remote add origin "$url" 2>/dev/null && \
                printf '%b✓ تم ربط origin%b\n' "$GRN" "$R" ;;
        esac
    fi
}

# ═══════ القائمة ═══════
show_menu(){
    clr
    printf '%b╔═══════════════════════════════════════╗%b\n' "$CYN" "$R"
    printf '%b║%b %b🎬  Movie BekEs  v%s%b            %b║%b\n' "$CYN" "$R" "$MAG$BOLD" "$VERSION" "$R" "$CYN" "$R"
    printf '%b║%b %b© 2025 B6_7E | بيكاس%b            %b║%b\n' "$CYN" "$R" "$DIM" "$R" "$CYN" "$R"
    printf '%b╚═══════════════════════════════════════╝%b\n' "$CYN" "$R"
    mc=0; cc=0
    [ -s "$DB_MOVIES" ]   && mc=$(wc -l < "$DB_MOVIES"   | tr -d ' ')
    [ -s "$DB_CHANNELS" ] && cc=$(wc -l < "$DB_CHANNELS" | tr -d ' ')
    printf '  الأفلام: %b%s%b   |   القنوات: %b%s%b\n\n' "$GRN" "$mc" "$R" "$GRN" "$cc" "$R"
    printf '  %b[1]%b 📽  عرض الأفلام\n'     "$WHT" "$R"
    printf '  %b[2]%b ➕  إضافة فيلم\n'       "$WHT" "$R"
    printf '  %b[3]%b ✏️   تعديل فيلم\n'      "$WHT" "$R"
    printf '  %b[4]%b 🗑  حذف فيلم\n'        "$WHT" "$R"
    printf '  %b─────────────────────────%b\n' "$DIM" "$R"
    printf '  %b[5]%b 📺  عرض القنوات\n'      "$WHT" "$R"
    printf '  %b[6]%b ➕  إضافة قناة\n'       "$WHT" "$R"
    printf '  %b[7]%b ✏️   تعديل قناة\n'      "$WHT" "$R"
    printf '  %b[8]%b 🗑  حذف قناة\n'        "$WHT" "$R"
    printf '  %b─────────────────────────%b\n' "$DIM" "$R"
    printf '  %b[9]%b 🚀  رفع إلى GitHub\n'   "$WHT" "$R"
    printf '  %b[0]%b 🚪  خروج\n'            "$WHT" "$R"
    printf '%b═══════════════════════════════════════%b\n' "$CYN" "$R"
    printf '%b▸ اختيارك: %b' "$GRN" "$R"
}

trap 'printf "\n%bوداعاً 👋%b\n" "$CYN" "$R"; exit 0' INT TERM

printf '%b\n🎬 Movie BekEs v%s\n%b%s%b\n\n' "$MAG$BOLD" "$VERSION" "$DIM" "$COPYRIGHT" "$R"
sleep 0.5
first_run

while true; do
    show_menu
    CH=""
    IFS= read -r CH || exit 0
    printf '\n'
    case "$CH" in
        1) list_movies;     pause_enter ;;
        2) add_movie;       pause_enter ;;
        3) edit_movie;      pause_enter ;;
        4) delete_movie;    pause_enter ;;
        5) list_channels;   pause_enter ;;
        6) add_channel;     pause_enter ;;
        7) edit_channel;    pause_enter ;;
        8) delete_channel;  pause_enter ;;
        9) save_all; git_push; pause_enter ;;
        0) printf '%bوداعاً 👋%b\n' "$CYN" "$R"; exit 0 ;;
        *) printf '%bاختيار غير صالح.%b\n' "$RED" "$R"; sleep 1 ;;
    esac
done