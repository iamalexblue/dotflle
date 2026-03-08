# ===============================================================
# 1. 路径与核心加载
# ===============================================================

# 如果你从 Bash 迁移过来，可能需要修改 $PATH
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Oh My Zsh 安装路径
export ZSH="$HOME/.oh-my-zsh"

# 主题设置 (daivasmara)
ZSH_THEME="eastwood"

# ===============================================================
# 2. Oh My Zsh 功能开关 (取消注释即可生效)
# ===============================================================

# 是否对补全开启大小写敏感
# CASE_SENSITIVE="true"

# 是否对连字符不敏感 (比如 _ 和 - 视为相同)
# HYPHEN_INSENSITIVE="true"

# 是否禁用自动更新检测
# zstyle ':omz:update' mode disabled

# 自动更新频率 (天)
# zstyle ':omz:update' frequency 13

# 是否禁用 ls 颜色
# DISABLE_LS_COLORS="true"

# 是否开启命令自动纠错
# ENABLE_CORRECTION="true"

# 等待补全时是否显示红点
# COMPLETION_WAITING_DOTS="true"

# ===============================================================
# 3. 插件配置
# ===============================================================

# 推荐顺序：基础插件 -> 自动建议 -> 语法高亮
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# 真正加载 Oh My Zsh 的地方
source $ZSH/oh-my-zsh.sh

# ===============================================================
# 4. 用户自定义配置 (User configuration)
# ===============================================================

# 语言环境
# export LANG=en_US.UTF-8

# 默认编辑器
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# ===============================================================
# 5. 代理管理 (Surge Proxy) - 你的核心自定义
# ===============================================================
export SURGE_PROXY="http://10.10.10.10:7890"

# 开启代理 (pon = Proxy On)
function pon() {
    export http_proxy="$SURGE_PROXY"
    export https_proxy="$SURGE_PROXY"
    export ftp_proxy="$SURGE_PROXY"
    export all_proxy="$SURGE_PROXY"
    printf "\033[32m[✔] Mihomo Proxy Enabled\033[0m\n"
}

# 关闭代理 (poff = Proxy Off)
function poff() {
    unset http_proxy https_proxy ftp_proxy all_proxy
    printf "\033[31m[✘] Mihomo Proxy Disabled\033[0m\n"
}

# 查看当前代理状态
alias pstatus='env | grep -i proxy'

# ===============================================================
# 6. 其他便捷别名
# ===============================================================
alias zshconfig="nvim ~/.zshrc"
alias reload="source ~/.zshrc"

# quick open gearlever alias
alias gearlever='flatpak run it.mijorus.gearlever'

# ---------------------------------------------
# 使用 lnav 查看 mihomo 实时日志（自带高亮和美化）
alias mlog='sudo journalctl -u mihomo -f | lnav -f /dev/stdin'
# 查看最近 50 行历史 (带高亮，不跟随)
alias mlog-last='sudo journalctl -u mihomo -n 50 --no-pager | lnav -f /dev/stdin'
# ---------------------------------------------

# bun completions
[ -s "/home/realexblue/.bun/_bun" ] && source "/home/realexblue/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# "y" shortcut to open "yazi"
function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
}
