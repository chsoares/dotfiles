# Carregar o Starship como Prompt
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# Carregar o brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Carregar o fzf
eval "$(fzf --zsh)"
export FZF_DEFAULT_OPTS="--ansi \
--color=fg:#f8f8f2,bg:#222222,hl:#bd93f9 \
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
--color=info:#bd93f9,prompt:#FFA800,pointer:#FF79C6 \
--color=marker:#FFA800,spinner:#FF79C6,header:#6272a4 \
--prompt="

zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)

# Habilitar autocomplete ignorando maiúsculas/minúsculas
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors  ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no

zstyle ':fzf-tab:complete:*' fzf-preview '
  if [[ -d $realpath ]]; then
    ls --color=auto "$realpath"
  elif [[ -f $realpath ]]; then
    cat "$realpath"
  fi'


# Garante que o compinit está carregado corretamente
autoload -Uz compinit && compinit

# Ativa pesquisa no histórico com setas para cima e para baixo
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -e
bindkey '^[[A' up-line-or-beginning-search   # Tecla para cima
bindkey '^[[B' down-line-or-beginning-search # Tecla para baixo
bindkey '^[OA' up-line-or-beginning-search   # Alternativa para terminais diferentes
bindkey '^[OB' down-line-or-beginning-search # Alternativa para terminais diferentes
bindkey '\e[1;5C' forward-word
bindkey '\e[1;5D' backward-word


# Histórico do Zsh com pesquisa incremental
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt incappendhistory

# Colors!
alias ls='lsd'
alias grep='grep --color=auto'
alias bat='batcat --paging=never'

# Ativar plugins essenciais
source ~/.zsh/zsh_plugins.sh

# Ativar venv
cd() {
    # Usa o cd interno do shell; se falhar, sai da função.
    builtin cd "$@" || return

    # Define o caminho absoluto para o diretório "venv" dentro do diretório atual.
    local venv_path="$(pwd)/venv"

    if [ -d "$venv_path" ]; then
        # Se existe um diretório "venv" no diretório atual…
        if [ "$VIRTUAL_ENV" != "$venv_path" ]; then
            # Se algum venv estiver ativo (mas não é o deste diretório), desativa-o.
            if [ -n "$VIRTUAL_ENV" ]; then
                deactivate
            fi
            # Ativa o venv encontrado.
            source "$venv_path/bin/activate"
        fi
    else
        # Se não houver "venv" no diretório atual e algum venv estiver ativo,
        # desativa-o para evitar que permaneça ativo em um contexto inadequado.
        if [ -n "$VIRTUAL_ENV" ]; then
            deactivate
        fi
    fi
}


# Ativa/desativa o dev.copic.app
dev() {
    echo ""
    echo -e "\033[0;36m[*]\033[0m Gerenciando ambiente de desenvolvimento \033[0;33mdev.copic.app\033[0m"
    echo ""

    case "$1" in
        start)
            echo -e "\033[0;36m[*]\033[0m Navegando até \033[0;33m/opt/copic.app-dev\033[0m"
            cd /opt/copic.app-dev || { echo -e "\033[0;31m[!]\033[0m Falha ao acessar /opt/copic.app-dev"; return 1; }

            echo -e "\033[0;36m[*]\033[0m Atualizando repositório..."
            git pull || { echo -e "\033[0;31m[!]\033[0m Erro ao executar git pull"; return 1; }

            echo -e "\033[0;36m[*]\033[0m Iniciando o serviço \033[0;33mstreamlit-dev\033[0m"
            sudo systemctl start streamlit-dev

            echo ""
            echo -e "\033[1;33mAmbiente de desenvolvimento iniciado com sucesso! 🚀\033[0m"
            ;;

        stop)
            echo -e "\033[0;36m[*]\033[0m Parando o serviço \033[0;33mstreamlit-dev\033[0m"
            sudo systemctl stop streamlit-dev

            echo ""
            echo -e "\033[1;33mAmbiente de desenvolvimento desligado. 🔌\033[0m"
            ;;

        status)
            echo -e "\033[0;36m[*]\033[0m Verificando status do serviço..."
            sudo systemctl status streamlit-dev --no-pager | head -n 3

            echo ""
            ;;

        *)
            echo -e "\033[0;31m[!]\033[0m Uso: dev {start|stop|status}"
            ;;
    esac
}


# fastfetch
clear
echo ""
fastfetch
