#!/usr/bin/env bash
# Calcola il nome della finestra:
#   - shell  -> percorso relativo alla radice del progetto (src/frontend/rms-app)
#   - altro  -> nome del comando in esecuzione (nvim, claude, ssh, ...)
#
# Serve uno script per due motivi:
#   1. durante il rename automatico tmux valuta il formato senza contesto di
#      sessione, quindi li' #{session_path} e' vuoto: lo chiediamo passando
#      il window_id;
#   2. tmux mostra l'output di #() con un ciclo di ritardo, quindi dopo un cd
#      il nome resterebbe indietro: se e' obsoleto lo correggiamo qui.

win="$1"
path="$2"
cmd="$3"

shell_name() {
	local root=""

	# la home nuda non ha bisogno di essere scritta per intero
	[ "$path" = "$HOME" ] && { printf '~\n'; return; }

	# 1. radice del repository git: e' l'ancora piu' affidabile.
	#    #{session_path} non va bene da solo: e' la cwd della sessione, che
	#    dopo un restore di resurrect punta alla directory del primo pane
	#    (per la sessione arms era .../arms/src/backend/rms, non .../arms).
	if [ -d "$path" ]; then
		root="$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)"
	fi

	# 2. fuori da un repo, ripiega sulla directory della sessione
	if [ -z "$root" ] && [ -n "$win" ]; then
		root="$(tmux display-message -p -t "$win" '#{session_path}' 2>/dev/null)"
	fi

	if [ -n "$root" ] && [ "$path" = "$root" ]; then
		printf '%s\n' "${path##*/}"        # siamo nella radice: solo il nome
	elif [ -n "$root" ] && [ "${path#"$root"/}" != "$path" ]; then
		printf '%s\n' "${path#"$root"/}"   # sotto la radice: percorso relativo
	else
		case "$path" in                    # fuori da tutto: almeno accorcia la home
			*"$HOME"/*) printf '~/%s\n' "${path#*"$HOME"/}" ;;
			*) printf '%s\n' "$path" ;;
		esac
	fi
}

case "$cmd" in
	sh | bash | zsh | fish | dash | ksh) name="$(shell_name)" ;;
	*) name="$cmd" ;;
esac

# Recupero del ritardo di un ciclo di #(): se il nome mostrato non e' piu'
# quello giusto lo impostiamo subito, riattivando automatic-rename (rename-window
# lo disattiva).
if [ -n "$win" ]; then
	current="$(tmux display-message -p -t "$win" '#{window_name}' 2>/dev/null)"
	if [ "$current" != "$name" ]; then
		{
			tmux rename-window -t "$win" "$name" &&
				tmux set-option -w -t "$win" automatic-rename on
		} >/dev/null 2>&1 &
	fi
fi

printf '%s\n' "$name"
