#!/bin/zsh

# Carregar o Starship como Prompt
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

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
    ls -A --color=auto "$realpath"
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

# Ativar aliases etc
source ~/.zsh/zsh_aliases
source /opt/ezpz/ezpz.sh
bash -c "setxkbmap -model abnt2 -layout br"
source ~/.zsh/zsh_env

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

# Título
preexec() {
  local words=("${(z)1}")  # quebra o comando preservando aspas e escapes
  LAST_CMD=""

  for word in "${words[@]}"; do
    [[ "$word" == -* ]] && break
    LAST_CMD+=" $word"
  done

  # Remove espaço inicial
  LAST_CMD="${LAST_CMD## }"

  print -Pn "\e]0;%n@%m: %~ :: ${LAST_CMD}\a"  
}

precmd() {
  print -Pn "\e]0;%n@%m: %~ :: ${LAST_CMD}\a"  
}

# fastfetch
fastfetch
