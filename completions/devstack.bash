# bash completion for devstack
# sourced by install.sh from ~/.bashrc - no bash-completion package required

_devstack() {
    local cur cword
    cur="${COMP_WORDS[COMP_CWORD]}"
    cword=$COMP_CWORD

    local commands="register edit list run down infra"

    if [ "$cword" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi

    local sub="${COMP_WORDS[1]}"
    case "$sub" in
        register|edit|run|down)
            if [ "$cword" -eq 2 ]; then
                local names
                names=$(devstack _names 2>/dev/null)
                COMPREPLY=( $(compgen -W "$names" -- "$cur") )
            fi
            ;;
        infra)
            if [ "$cword" -eq 2 ]; then
                COMPREPLY=( $(compgen -W "up down" -- "$cur") )
            fi
            ;;
    esac
    return 0
}

complete -F _devstack devstack
