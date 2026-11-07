#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
#  Movie BekEs — لوحة التحكم الاحترافية العالمية (Neon Edition)
#  الإصدار: 6.6 (شعار عملاق + إصلاح الاستيراد)
#  © 2025 B6_7E | بيكاس — جميع الحقوق محفوظة
# ═══════════════════════════════════════════════════════════════════════

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

set -u
VERSION="6.6"
COPYRIGHT="© 2025 B6_7E | بيكاس"
GIT_MSG="Update content"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR" 2>/dev/null || { printf 'تعذر الدخول\n'; exit 1; }

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

# ═══════════════════════════════════════════════════════════════════════
#  🎨 الشعار العملاق — Block Art + Rainbow Neon
# ═══════════════════════════════════════════════════════════════════════
show_logo() {
    # ═══ الجزء 1: M O V I E ═══
    printf "\033[38;5;21m    \033[38;5;27m╔══════════════════════════════════════════════════════════╗\033[0m\n"
    printf "\033[38;5;21m    \033[38;5;27m║\033[38;5;51m                                                          \033[38;5;27m║\033[0m\n"
    printf "\033[38;5;57m    \033[38;5;63m║\033[0m  \033[38;5;226m███╗   ███╗ ██████╗ ██╗   ██╗██╗███████╗\033[0m              \033[38;5;63m║\033[0m\n"
    printf "\033[38;5;57m    \033[38;5;63m║\033[0m  \033[38;5;220m████╗ ████║██╔═══██╗██║   ██║██║██╔════╝\033[0m              \033[38;5;63m║\033[0m\n"
    printf "\033[38;5;93m    \033[38;5;99m║\033[0m  \033[38;5;214m██╔████╔██║██║   ██║██║   ██║██║█████╗  \033[0m              \033[38;5;99m║\033[0m\n"
    printf "\033[38;5;93m    \033[38;5;99m║\033[0m  \033[38;5;208m██║╚██╔╝██║██║   ██║╚██╗ ██╔╝██║██╔══╝  \033[0m              \033[38;5;99m║\033[0m\n"
    printf "\033[38;5;129m    \033[38;5;135m║\033[0m  \033[38;5;202m██║ ╚═╝ ██║╚██████╔╝ ╚████╔╝ ██║███████╗\033[0m              \033[38;5;135m║\033[0m\n"
    printf "\033[38;5;129m    \033[38;5;135m║\033[0m  \033[38;5;196m╚═╝     ╚═╝ ╚═════╝   ╚═══╝  ╚═╝╚══════╝\033[0m              \033[38;5;135m║\033[0m\n"
    printf "\033[38;5;165m    \033[38;5;171m║\033[38;5;51m                                                          \033[38;5;171m║\033[0m\n"
    # ═══ الجزء 2: B E K E S ═══
    printf "\033[38;5;165m    \033[38;5;171m║\033[0m  \033[38;5;46m██████╗ ███████╗██╗  ██╗███████╗███████╗\033[0m              \033[38;5;171m║\033[0m\n"
    printf "\033[38;5;201m    \033[38;5;207m║\033[0m  \033[38;5;51m██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔════╝\033[0m              \033[38;5;207m║\033[0m\n"
    printf "\033[38;5;201m    \033[38;5;207m║\033[0m  \033[38;5;45m██████╔╝█████╗  █████╔╝ █████╗  ███████╗\033[0m              \033[38;5;207m║\033[0m\n"
    printf "\033[38;5;213m    \033[38;5;219m║\033[0m  \033[38;5;39m██╔══██╗██╔══╝  ██╔═██╗ ██╔══╝  ╚════██║\033[0m              \033[38;5;219m║\033[0m\n"
    printf "\033[38;5;213m    \033[38;5;219m║\033[0m  \033[38;5;33m██████╔╝███████╗██║  ██╗███████╗███████║\033[0m              \033[38;5;219m║\033[0m\n"
    printf "\033[38;5;225m    \033[38;5;231m║\033[0m  \033[38;5;27m╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝\033[0m              \033[38;5;231m║\033[0m\n"
    printf "\033[38;5;225m    \033[38;5;231m║\033[38;5;51m                                                          \033[38;5;231m║\033[0m\n"
    # ═══ الجزء 3: الشعار والتوقيع ═══
    printf "\033[38;5;231m    \033[38;5;231m║\033[0m       \033[38;5;226m★  P R O   E D I T I O N  ·  v$VERSION  ★\033[0m         \033[38;5;231m║\033[0m\n"
    printf "\033[38;5;231m    \033[38;5;231m║\033[0m            \033[38;5;51m© 2025 B6_7E  |  بيكاس\033[0m                     \033[38;5;231m║\033[0m\n"
    printf "\033[38;5;231m    \033[38;5;231m╚══════════════════════════════════════════════════════════╝\033[0m\n"
    printf "\n"
    printf "     \033[38;5;213m✦ \033[38;5;51m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[38;5;213m✦\033[0m\n"
    printf "     \033[38;5;213m✦ \033[38;5;226m CINEMA MANAGEMENT SYSTEM \033[38;5;51m·\033[38;5;226m NEON EDITION \033[38;5;213m✦\033[0m\n"
    printf "     \033[38;5;213m✦ \033[38;5;51m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[38;5;213m✦\033[0m\n\n"
}

# ─── دوال الواجهة ───
clr(){ command -v clear >/dev/null 2>&1 && clear 2>/dev/null || printf '\033[2J\033[H'; }

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    printf "  \033[38;5;226m[ جاري المعالجة ] \033[0m "
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\033[38;5;51m[%c]\033[0m" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

notify(){
    local type="$1" title="$2" msg="$3"
    if [ "$type" = "ok" ]; then
        printf "\n\033[38;5;46m +------------------------------------------+ \033[0m\n"
        printf "\033[38;5;46m | \033[38;5;231m[+] %s\033[0m\n" "$title"
        printf "\033[38;5;46m | \033[38;5;244m%s\033[0m\n" "$msg"
        printf "\033[38;5;46m +------------------------------------------+ \033[0m\n"
    elif [ "$type" = "err" ]; then
        printf "\n\033[38;5;196m +------------------------------------------+ \033[0m\n"
        printf "\033[38;5;196m | \033[38;5;231m[!] %s\033[0m\n" "$title"
        printf "\033[38;5;196m | \033[38;5;244m%s\033[0m\n" "$msg"
        printf "\033[38;5;196m +------------------------------------------+ \033[0m\n"
    else
        printf "\n\033[38;5;39m +------------------------------------------+ \033[0m\n"
        printf "\033[38;5;39m | \033[38;5;231m[i] %s\033[0m\n" "$title"
        printf "\033[38;5;39m | \033[38;5;244m%s\033[0m\n" "$msg"
        printf "\033[38;5;39m +------------------------------------------+ \033[0m\n"
    fi
    printf "\a"
    printf '\033]0;%s\007' "$title"
}

jesc(){ printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

save_movies_json(){
    first=1
    {
        printf '{\n  "movies": [\n'
        if [ -s "$DB_MOVIES" ]; then
            while IFS="$US" read -r t y g r p s u l; do
                [ -z "${t:-}" ] && continue
                [ "$first" -eq 0 ] && printf '    },\n'
                first=0
                esc_u=$(jesc "${u:-}")
                esc_l=$(jesc "${l:-}")
                printf '    {\n      "title": "%s",\n      "year": %s,\n      "genre": "%s",\n      "rating": %s,\n      "poster": "%s",\n      "story": "%s",\n      "sources": [\n' \
                    "$(jesc "$t")" "${y:-0}" "$(jesc "${g:-عام}")" "${r:-0}" \
                    "$(jesc "${p:-}")" "$(jesc "${s:-}")"
                awk -v urls="$esc_u" -v labels="$esc_l" 'BEGIN {
                    n=split(urls, u_arr, ";;;")
                    m=split(labels, l_arr, ";;;")
                    for(i=1; i<=n; i++) {
                        if(i>1) printf "        },\n"
                        printf "        {\n          \"label\": \"%s\",\n          \"url\": \"%s\"\n", (i<=m && l_arr[i]!="" ? l_arr[i] : "سيرفر"), u_arr[i]
                    }
                    if (n>0) printf "        }\n"
                }'
                printf '      ]'
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
                esc_u=$(jesc "${u:-}")
                esc_l=$(jesc "${l:-}")
                printf '\n    {"title":"%s","year":%s,"genre":"%s","rating":%s,"poster":"%s","story":"%s",' \
                    "$(jesc "$t")" "${y:-0}" "$(jesc "${g:-عام}")" "${r:-0}" \
                    "$(jesc "${p:-}")" "$(jesc "${s:-}")"
                awk -v urls="$esc_u" -v labels="$esc_l" 'BEGIN {
                    n=split(urls, u_arr, ";;;")
                    m=split(labels, l_arr, ";;;")
                    printf "\"sources\":["
                    for(i=1; i<=n; i++) {
                        if(i>1) printf ","
                        printf "{\"label\":\"%s\",\"url\":\"%s\"}", (i<=m && l_arr[i]!="" ? l_arr[i] : "سيرفر"), u_arr[i]
                    }
                    printf "]"
                }'
                printf '}'
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

GIT_USER="${GIT_USER:-}"
GIT_PASS="${GIT_PASS:-}"

_do_git_push(){
    tmp=$(mktemp 2>/dev/null || echo "/tmp/gitpush.$$")
    if GIT_TERMINAL_PROMPT=0 git push >"$tmp" 2>&1; then rm -f "$tmp"; return 0; fi
    if grep -qiE 'authentication|permission denied|403|could not read username|terminal prompts disabled|fatal: could not read' "$tmp"; then
        rm -f "$tmp"; return 1
    fi
    cp "$tmp" /tmp/cp_last_err 2>/dev/null
    rm -f "$tmp"; return 2
}

_prompt_credentials(){
    printf '\n\033[38;5;226m +-- [ مصادقة GitHub ] --------------------+ \033[0m\n'
    printf '\033[38;5;226m |\033[0m (استخدم Personal Access Token)\n'
    printf '\033[38;5;226m +------------------------------------------+ \033[0m\n'
    printf ' اسم المستخدم: '; IFS= read -r GIT_USER || GIT_USER=""
    printf ' كلمة المرور / التوكن: '; IFS= read -r GIT_PASS || GIT_PASS=""
    [ -z "$GIT_USER" ] || [ -z "$GIT_PASS" ] && return 1
    return 0
}

git_push(){
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        notify "err" "Git" "ليس مستودع git"
        return 1
    fi
    git add --all >/dev/null 2>&1
    git commit --allow-empty -m "$GIT_MSG" >/dev/null 2>&1
    printf "\n"
    ( _do_git_push; exit $? ) &
    spinner $!
    wait $!
    rc=$?
    if [ "$rc" -eq 0 ]; then notify "ok" "GitHub" "تم الرفع بنجاح"; return 0; fi
    if [ "$rc" -eq 1 ]; then
        if _prompt_credentials; then
            REPO_URL=$(git remote get-url origin 2>/dev/null)
            [ -z "$REPO_URL" ] && { notify "err" "خطأ" "لا يوجد origin"; return 1; }
            case "$REPO_URL" in
                git@*) REPO_URL=$(printf '%s' "$REPO_URL" | sed -E 's#git@([^:]+):([^/]+)/(.+)#https://\1/\2/\3#') ;;
            esac
            AUTH_URL=$(printf '%s' "$REPO_URL" | sed -E "s#^https://#https://${GIT_USER}:${GIT_PASS}@#")
            printf "\n"
            ( GIT_TERMINAL_PROMPT=0 git push "$AUTH_URL" >/tmp/cp_git.$$ 2>&1; exit $? ) &
            spinner $!
            wait $!
            if [ $? -eq 0 ]; then
                rm -f /tmp/cp_git.$$
                notify "ok" "GitHub" "تم الرفع بعد المصادقة"; return 0
            fi
            notify "err" "GitHub" "فشلت المصادقة"
            tail -5 /tmp/cp_git.$$ 2>/dev/null | sed 's/^/  /'
            rm -f /tmp/cp_git.$$
            return 1
        else
            notify "err" "GitHub" "تم إلغاء الرفع"; return 1
        fi
    fi
    notify "err" "GitHub" "فشل الرفع"
    tail -5 /tmp/cp_last_err 2>/dev/null | sed 's/^/  /'
    rm -f /tmp/cp_last_err
    return 1
}

ask(){
    if [ -n "$2" ]; then
        printf ' \033[38;5;51m> %s\033[0m \033[2m[%s]\033[0m: ' "$1" "$2"
    else
        printf ' \033[38;5;51m> %s\033[0m: ' "$1"
    fi
    IFS= read -r ans || ans=""
    if [ "$ans" = "--" ]; then ans=""
    elif [ -z "$ans" ] && [ -n "$2" ]; then ans="$2"
    fi
    ASK_RESULT="$ans"
}
pause_enter(){ printf '\n \033[2mاضغط Enter...\033[0m'; IFS= read -r _ || true; }

list_movies(){
    if [ ! -s "$DB_MOVIES" ]; then printf '  \033[2m(لا توجد أفلام)\033[0m\n'; return; fi
    i=0
    while IFS="$US" read -r t y g r p s u l; do
        [ -z "${t:-}" ] && continue
        i=$((i+1)); w=""
        [ -z "${p:-}" ] && w="$w \033[38;5;226m[ناقص غلاف]\033[0m"
        if [ -z "${u:-}" ]; then
            w="$w \033[38;5;226m[ناقص رابط]\033[0m"
        else
            srv_cnt=$(printf '%s' "$u" | awk -F';;;' '{print NF}')
            w="$w \033[38;5;39m(${srv_cnt} سيرفر)\033[0m"
        fi
        printf '  \033[38;5;201m[%02d]\033[0m %s \033[2m(%s)\033[0m - %s - نجمة %s%b\n' \
            "$i" "$t" "${y:-?}" "${g:-?}" "${r:-?}" "$w"
    done < "$DB_MOVIES"
}
list_channels(){
    if [ ! -s "$DB_CHANNELS" ]; then printf '  \033[2m(لا توجد قنوات)\033[0m\n'; return; fi
    i=0
    while IFS="$US" read -r n p s d; do
        [ -z "${n:-}" ] && continue
        i=$((i+1)); w=""
        [ -z "${p:-}" ] && w="$w \033[38;5;226m[ناقص غلاف]\033[0m"
        [ -z "${s:-}" ] && w="$w \033[38;5;226m[ناقص بث]\033[0m"
        printf '  \033[38;5;201m[%02d]\033[0m %s - %s%b\n' "$i" "$n" "${d:-}" "$w"
    done < "$DB_CHANNELS"
}

add_movie(){
    clr; show_logo; printf '\033[38;5;201m=== [+] إضافة فيلم جديد ===\033[0m\n\n'
    am_t=""
    while [ -z "$am_t" ]; do ask "عنوان الفيلم" ""; am_t="$ASK_RESULT"; [ -z "$am_t" ] && printf '  \033[38;5;196mمطلوب!\033[0m\n'; done
    ask "السنة" "$(date +%Y 2>/dev/null || echo 2025)"; am_y="$ASK_RESULT"
    ask "التصنيف" "عام"; am_g="$ASK_RESULT"
    ask "التقييم (0-10)" "0"; am_r="$ASK_RESULT"
    ask "رابط الغلاف" ""; am_p="$ASK_RESULT"
    am_u=""; am_l=""
    while true; do
        ask "رابط المشاهدة" ""; curr_url="$ASK_RESULT"
        while [ -z "$curr_url" ]; do printf '  \033[38;5;196mمطلوب!\033[0m\n'; ask "رابط المشاهدة" ""; curr_url="$ASK_RESULT"; done
        ask "تسمية السيرفر" "سيرفر رئيسي"; curr_label="$ASK_RESULT"
        if [ -z "$am_u" ]; then
            am_u="$curr_url"; am_l="$curr_label"
        else
            am_u="${am_u};;;${curr_url}"; am_l="${am_l};;;${curr_label}"
        fi
        ask "هل تريد إضافة سيرفر آخر؟ (y/N)" "n"; more="$ASK_RESULT"
        case "$more" in y|Y|yes|YES) continue ;; *) break ;; esac
    done
    ask "القصة (اختياري)" ""; am_s="$ASK_RESULT"
    printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
        "$am_t" "$US" "$am_y" "$US" "$am_g" "$US" "$am_r" "$US" \
        "$am_p" "$US" "$am_s" "$US" "$am_u" "$US" "$am_l" >> "$DB_MOVIES"
    save_all; notify "ok" "نجاح" "تمت إضافة: $am_t"; git_push
}

edit_movie(){
    clr; show_logo; printf '\033[38;5;201m=== [*] تعديل فيلم ===\033[0m\n'; list_movies; printf '\n'
    printf ' \033[38;5;51m> رقم الفيلم (0=إلغاء)\033[0m: '
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "err" "خطأ" "رقم غير صالح"; return 1;; esac
    ln=1; found=0; et=""; ey=""; eg=""; er=""; ep=""; es=""; eu=""; el=""
    while IFS="$US" read -r t y g r p s u l; do
        if [ "$ln" -eq "$idx" ]; then et="$t"; ey="$y"; eg="$g"; er="$r"; ep="$p"; es="$s"; eu="$u"; el="$l"; found=1; break; fi
        ln=$((ln+1))
    done < "$DB_MOVIES"
    [ "$found" -eq 0 ] && { notify "err" "خطأ" "رقم غير موجود"; return 1; }
    printf '\n \033[2m(فارغ = احتفاظ، -- = تفريغ)\033[0m\n\n'
    ask "العنوان" "$et"; nt="$ASK_RESULT"
    ask "السنة" "$ey"; ny="$ASK_RESULT"
    ask "التصنيف" "$eg"; ng="$ASK_RESULT"
    ask "التقييم" "$er"; nr="$ASK_RESULT"
    ask "رابط الغلاف" "$ep"; np="$ASK_RESULT"
    printf '\n\033[38;5;226m> تعديل السيرفرات؟ (y/N)\033[0m: '
    IFS= read -r edit_srv || edit_srv=""
    case "$edit_srv" in
        y|Y|yes|YES)
            nu="$eu"; nl="$el"
            while true; do
                printf "\n\033[38;5;51mالسيرفرات الحالية:\033[0m\n"
                echo "$nu" | awk -F';;;' '{for(i=1;i<=NF;i++) print "  [" i "] " $i}'
                printf ' \033[38;5;51m> رقم للتعديل (0=إضافة، d=حذف، Enter=إنهاء)\033[0m: '
                IFS= read -r srv_idx || srv_idx=""
                [ -z "$srv_idx" ] && break
                if [ "$srv_idx" = "0" ]; then
                    ask "رابط جديد" ""; curr_url="$ASK_RESULT"
                    while [ -z "$curr_url" ]; do printf '  \033[38;5;196mمطلوب!\033[0m\n'; ask "رابط جديد" ""; curr_url="$ASK_RESULT"; done
                    ask "تسمية" "سيرفر"; curr_label="$ASK_RESULT"
                    if [ -z "$nu" ]; then nu="$curr_url"; nl="$curr_label"; else nu="${nu};;;${curr_url}"; nl="${nl};;;${curr_label}"; fi
                    printf '  \033[38;5;46mتمت الإضافة.\033[0m\n'
                elif [ "$srv_idx" = "d" ] || [ "$srv_idx" = "D" ]; then
                    printf ' \033[38;5;51m> رقم للحذف: \033[0m'
                    IFS= read -r del_idx || del_idx=""
                    if [ -n "$del_idx" ]; then
                        case "$del_idx" in *[!0-9]*) printf '  \033[38;5;196mرقم غير صالح!\033[0m\n'; continue ;; esac
                        nu=$(echo "$nu" | awk -F';;;' -v i="$del_idx" '{c=0; for(j=1;j<=NF;j++){if(j!=i){c++;if(c>1)printf ";;;";printf "%s",$j}}}')
                        nl=$(echo "$nl" | awk -F';;;' -v i="$del_idx" '{c=0; for(j=1;j<=NF;j++){if(j!=i){c++;if(c>1)printf ";;;";printf "%s",$j}}}')
                        printf '  \033[38;5;46mتم الحذف.\033[0m\n'
                    fi
                else
                    case "$srv_idx" in *[!0-9]*) printf '  \033[38;5;196mرقم غير صالح!\033[0m\n'; continue ;; esac
                    old_url=$(echo "$nu" | awk -F';;;' -v i="$srv_idx" '{print $i}')
                    old_label=$(echo "$nl" | awk -F';;;' -v i="$srv_idx" '{print $i}')
                    ask "رابط" "$old_url"; new_url="$ASK_RESULT"
                    ask "تسمية" "$old_label"; new_label="$ASK_RESULT"
                    nu=$(echo "$nu" | awk -F';;;' -v i="$srv_idx" -v nv="$new_url" '{for(j=1;j<=NF;j++){if(j==i)printf "%s",nv;else printf "%s",$j;if(j<NF)printf ";;;"}}')
                    nl=$(echo "$nl" | awk -F';;;' -v i="$srv_idx" -v nv="$new_label" '{for(j=1;j<=NF;j++){if(j==i)printf "%s",nv;else printf "%s",$j;if(j<NF)printf ";;;"}}')
                    printf '  \033[38;5;46mتم التحديث.\033[0m\n'
                fi
            done
            ;;
        *) nu="$eu"; nl="$el" ;;
    esac
    ask "القصة" "$es"; ns="$ASK_RESULT"
    awk -v target="$idx" -v t="$nt" -v y="$ny" -v g="$ng" -v r="$nr" -v p="$np" -v s="$ns" -v u="$nu" -v l="$nl" '
        BEGIN { US = sprintf("%c",31) }
        NR==target { print t US y US g US r US p US s US u US l; next }
        { print }' "$DB_MOVIES" > "$DB_MOVIES.tmp" && mv "$DB_MOVIES.tmp" "$DB_MOVIES"
    save_all; notify "ok" "نجاح" "تم التعديل: $nt"; git_push
}

delete_movie(){
    clr; show_logo; printf '\033[38;5;196m=== [-] حذف فيلم ===\033[0m\n'; list_movies; printf '\n'
    printf ' \033[38;5;51m> رقم الفيلم (0=إلغاء)\033[0m: '
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "err" "خطأ" "رقم غير صالح"; return 1;; esac
    printf ' \033[38;5;226m> متأكد؟ (y/N)\033[0m: '
    IFS= read -r c || c=""
    case "$c" in y|Y|yes|YES) :;; *) printf ' \033[2mأُلغي.\033[0m\n'; return 0;; esac
    name=$(awk -v n="$idx" -v US="$US" 'BEGIN{FS=US} NR==n{print $1; exit}' "$DB_MOVIES")
    awk -v target="$idx" 'NR!=target' "$DB_MOVIES" > "$DB_MOVIES.tmp" && mv "$DB_MOVIES.tmp" "$DB_MOVIES"
    save_all; notify "ok" "نجاح" "تم الحذف: $name"; git_push
}

add_channel(){
    clr; show_logo; printf '\033[38;5;201m=== [+] إضافة قناة جديدة ===\033[0m\n\n'
    ac_n=""
    while [ -z "$ac_n" ]; do ask "اسم القناة" ""; ac_n="$ASK_RESULT"; [ -z "$ac_n" ] && printf '  \033[38;5;196mمطلوب!\033[0m\n'; done
    ask "رابط الغلاف" ""; ac_p="$ASK_RESULT"
    ac_s=""
    while [ -z "$ac_s" ]; do ask "رابط البث المباشر" ""; ac_s="$ASK_RESULT"; [ -z "$ac_s" ] && printf '  \033[38;5;196mمطلوب!\033[0m\n'; done
    ask "الوصف" "قناة $ac_n - بث مباشر"; ac_d="$ASK_RESULT"
    printf '%s%s%s%s%s%s%s\n' "$ac_n" "$US" "$ac_p" "$US" "$ac_s" "$US" "$ac_d" >> "$DB_CHANNELS"
    save_all; notify "ok" "نجاح" "تمت الإضافة: $ac_n"; git_push
}

edit_channel(){
    clr; show_logo; printf '\033[38;5;201m=== [*] تعديل قناة ===\033[0m\n'; list_channels; printf '\n'
    printf ' \033[38;5;51m> رقم القناة (0=إلغاء)\033[0m: '
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "err" "خطأ" "رقم غير صالح"; return 1;; esac
    ln=1; found=0; en=""; ep=""; es=""; ed=""
    while IFS="$US" read -r n p s d; do
        if [ "$ln" -eq "$idx" ]; then en="$n"; ep="$p"; es="$s"; ed="$d"; found=1; break; fi
        ln=$((ln+1))
    done < "$DB_CHANNELS"
    [ "$found" -eq 0 ] && { notify "err" "خطأ" "رقم غير موجود"; return 1; }
    printf '\n \033[2m(فارغ = احتفاظ، -- = تفريغ)\033[0m\n\n'
    ask "الاسم" "$en"; nn="$ASK_RESULT"
    ask "الغلاف" "$ep"; np="$ASK_RESULT"
    ask "رابط البث" "$es"; ns="$ASK_RESULT"
    ask "الوصف" "$ed"; nd="$ASK_RESULT"
    awk -v target="$idx" -v n="$nn" -v p="$np" -v s="$ns" -v d="$nd" '
        BEGIN { US = sprintf("%c",31) }
        NR==target { print n US p US s US d; next }
        { print }' "$DB_CHANNELS" > "$DB_CHANNELS.tmp" && mv "$DB_CHANNELS.tmp" "$DB_CHANNELS"
    save_all; notify "ok" "نجاح" "تم التعديل: $nn"; git_push
}

delete_channel(){
    clr; show_logo; printf '\033[38;5;196m=== [-] حذف قناة ===\033[0m\n'; list_channels; printf '\n'
    printf ' \033[38;5;51m> رقم القناة (0=إلغاء)\033[0m: '
    IFS= read -r idx || idx=""
    { [ -z "$idx" ] || [ "$idx" = "0" ]; } && return 0
    case "$idx" in *[!0-9]*) notify "err" "خطأ" "رقم غير صالح"; return 1;; esac
    printf ' \033[38;5;226m> متأكد؟ (y/N)\033[0m: '
    IFS= read -r c || c=""
    case "$c" in y|Y|yes|YES) :;; *) printf ' \033[2mأُلغي.\033[0m\n'; return 0;; esac
    name=$(awk -v n="$idx" -v US="$US" 'BEGIN{FS=US} NR==n{print $1; exit}' "$DB_CHANNELS")
    awk -v target="$idx" 'NR!=target' "$DB_CHANNELS" > "$DB_CHANNELS.tmp" && mv "$DB_CHANNELS.tmp" "$DB_CHANNELS"
    save_all; notify "ok" "نجاح" "تم الحذف: $name"; git_push
}

first_run(){
    if [ ! -s "$DB_MOVIES" ] && [ -f "$JSON_MOVIES" ]; then
        printf '\033[38;5;226m وجدت movies.json - استيراد؟ (y/N)\033[0m: '
        IFS= read -r a || a=""
        case "$a" in y|Y) 
            awk 'BEGIN{US=sprintf("%c",31);inm=0;t="";y="0";g="عام";r="0";p="";s="";u="";l="";ucnt=0;lcnt=0}
            /^    \{/{inm=1;t="";y="0";g="عام";r="0";p="";s="";u="";l="";ucnt=0;lcnt=0;next}
            inm&&/^    \},?$/{if(t!="")print t US y US g US r US p US s US u US l;inm=0;next}
            inm&&/"title":/{v=$0;sub(/.*"title": *"/,"",v);sub(/".*/,"",v);t=v}
            inm&&/"year":/{v=$0;sub(/.*"year": */,"",v);sub(/[,"].*/,"",v);y=v}
            inm&&/"genre":/{v=$0;sub(/.*"genre": *"/,"",v);sub(/".*/,"",v);g=v}
            inm&&/"rating":/{v=$0;sub(/.*"rating": */,"",v);sub(/[,"].*/,"",v);r=v}
            inm&&/"poster":/{v=$0;sub(/.*"poster": *"/,"",v);sub(/".*/,"",v);p=v}
            inm&&/"story":/{v=$0;sub(/.*"story": *"/,"",v);sub(/".*/,"",v);s=v}
            inm&&/"url":/{v=$0;sub(/.*"url": *"/,"",v);sub(/".*/,"",v);if(ucnt==0){u=v}else{u=u";;;"v};ucnt++}
            inm&&/"label":/{v=$0;sub(/.*"label": *"/,"",v);sub(/".*/,"",v);if(lcnt==0){l=v}else{l=l";;;"v};lcnt++}' \
            "$JSON_MOVIES" > "$DB_MOVIES"
            notify "ok" "استيراد" "$(wc -l < "$DB_MOVIES" | tr -d ' ') فيلم" ;;
        esac
    fi
    if [ ! -s "$DB_CHANNELS" ] && [ -f "$JSON_CHANNELS" ]; then
        printf '\033[38;5;226m وجدت channels.json - استيراد؟ (y/N)\033[0m: '
        IFS= read -r a || a=""
        case "$a" in y|Y)
            awk 'BEGIN{US=sprintf("%c",31);inc=0;n="";p="";s="";d=""}
            /^    \{/{inc=1;n="";p="";s="";d="";next}
            inc&&/^    \},?$/{if(n!="")print n US p US s US d;inc=0;next}
            inc&&/"name":/{v=$0;sub(/.*"name": *"/,"",v);sub(/".*/,"",v);n=v}
            inc&&/"poster":/{v=$0;sub(/.*"poster": *"/,"",v);sub(/".*/,"",v);p=v}
            inc&&/"stream":/{v=$0;sub(/.*"stream": *"/,"",v);sub(/".*/,"",v);s=v}
            inc&&/"desc":/{v=$0;sub(/.*"desc": *"/,"",v);sub(/".*/,"",v);d=v}' \
            "$JSON_CHANNELS" > "$DB_CHANNELS"
            notify "ok" "استيراد" "$(wc -l < "$DB_CHANNELS" | tr -d ' ') قناة" ;;
        esac
    fi
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf '\n\033[38;5;226m[!] لا يوجد git - تهيئة؟ (y/N): \033[0m'
        IFS= read -r a || a=""
        case "$a" in y|Y)
            git init >/dev/null 2>&1
            printf ' رابط المستودع: '
            IFS= read -r url || url=""
            [ -n "$url" ] && git remote add origin "$url" 2>/dev/null
            ;;
        esac
    fi
}

show_menu(){
    clr
    show_logo
    mc=0; cc=0
    [ -s "$DB_MOVIES" ]   && mc=$(wc -l < "$DB_MOVIES"   | tr -d ' ')
    [ -s "$DB_CHANNELS" ] && cc=$(wc -l < "$DB_CHANNELS" | tr -d ' ')
    printf "\033[38;5;51m +------------------------------------------+ \033[0m\n"
    printf "\033[38;5;51m | \033[0mالأفلام: \033[38;5;231m%-4s\033[0m \033[38;5;51m| \033[0mالقنوات: \033[38;5;231m%-4s\033[0m \033[38;5;51m|\033[0m\n" "$mc" "$cc"
    printf "\033[38;5;51m +------------------------------------------+ \033[0m\n\n"
    printf "  \033[38;5;201m[1]\033[0m عرض الأفلام           \033[38;5;201m[5]\033[0m عرض القنوات\n"
    printf "  \033[38;5;201m[2]\033[0m إضافة فيلم            \033[38;5;201m[6]\033[0m إضافة قناة\n"
    printf "  \033[38;5;201m[3]\033[0m تعديل فيلم            \033[38;5;201m[7]\033[0m تعديل قناة\n"
    printf "  \033[38;5;201m[4]\033[0m حذف فيلم              \033[38;5;201m[8]\033[0m حذف قناة\n"
    printf "\n \033[2m----------------------------------------------\033[0m\n"
    printf "  \033[38;5;39m[9]\033[0m رفع إلى GitHub         \033[38;5;196m[0]\033[0m خروج\n"
    printf " \033[2m----------------------------------------------\033[0m\n"
    printf "\n \033[38;5;46m> اختيارك:\033[0m "
}

trap 'printf "\n\033[38;5;51mوداعاً\033[0m\n"; exit 0' INT TERM

clr
show_logo
sleep 0.8

first_run

while true; do
    show_menu
    CH=""
    IFS= read -r CH || exit 0
    printf '\n'
    case "$CH" in
        1) clr; show_logo; list_movies;     pause_enter ;;
        2) add_movie;       pause_enter ;;
        3) edit_movie;      pause_enter ;;
        4) delete_movie;    pause_enter ;;
        5) clr; show_logo; list_channels;   pause_enter ;;
        6) add_channel;     pause_enter ;;
        7) edit_channel;    pause_enter ;;
        8) delete_channel;  pause_enter ;;
        9) save_all; git_push; pause_enter ;;
        0) printf ' \033[38;5;51mوداعاً\033[0m\n'; exit 0 ;;
        *) printf ' \033[38;5;196mاختيار غير صالح.\033[0m\n'; sleep 1 ;;
    esac
done