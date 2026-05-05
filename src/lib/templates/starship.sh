## Starship setup templates
## This file is located in 'src/lib/templates/starship.sh'



# Returns a curated default ~/.config/starship.toml tuned for devops workflows.
# Requires a Nerd Font for glyphs. Disable individual modules by setting
# `disabled = true` or remove them from the `format` string.
template_starship_config() {
  cat <<'EOF'
# ~/.config/starship.toml — managed by os-scripts
# Curated default for devops workflows. Requires a Nerd Font:
#   https://www.nerdfonts.com
# Browse alternative presets:  starship preset list
# Apply a preset:              starship preset tokyo-night -o ~/.config/starship.toml
# Full reference:              https://starship.rs/config/

"$schema" = "https://starship.rs/config-schema.json"

# Two-line layout: context on top, prompt char on a fresh line
format = """
$os\
$username\
$directory\
$git_branch\
$git_status\
$git_state\
$kubernetes\
$aws\
$gcloud\
$azure\
$docker_context\
$package\
$nodejs\
$python\
$golang\
$rust\
$java\
$terraform\
$cmd_duration\
$line_break\
$character"""

add_newline = true
command_timeout = 1500
scan_timeout = 30

[character]
success_symbol = "[❯](bold green)"
error_symbol   = "[❯](bold red)"
vimcmd_symbol  = "[❮](bold green)"

[directory]
style             = "bold cyan"
truncation_length = 4
truncate_to_repo  = true
read_only         = " "
read_only_style   = "red"
home_symbol       = "~"

[git_branch]
symbol = " "
style  = "bold purple"
format = "on [$symbol$branch]($style) "

[git_status]
style      = "bold red"
ahead      = "⇡${count}"
behind     = "⇣${count}"
diverged   = "⇕⇡${ahead_count}⇣${behind_count}"
conflicted = "="
modified   = "!"
staged     = "+"
untracked  = "?"
deleted    = "✘"
stashed    = "$"

[kubernetes]
disabled         = false
symbol           = "☸ "
style            = "bold blue"
format           = '[$symbol$context( \($namespace\))]($style) '
detect_files     = ['k8s', 'kubeconfig', 'Chart.yaml']
detect_extensions = ['yaml', 'yml']
contexts = [
  { context_pattern = ".*[pP][rR][oO][dD].*",  style = "bold red", context_alias = "PROD ⚠" },
  { context_pattern = ".*[sS][tT][aA][gG].*",  style = "bold yellow" },
]

[docker_context]
symbol          = " "
style           = "bold blue"
only_with_files = true

[aws]
symbol = "☁️  "
style  = "bold yellow"
format = '[$symbol($profile )(\($region\) )]($style)'

[gcloud]
symbol = "☁️  "
style  = "bold blue"
format = '[$symbol$account(@$domain)(\($region\))]($style) '

[azure]
symbol = "☁️  "
style  = "bold blue"
format = '[$symbol($subscription)]($style) '

[package]
symbol = "📦 "
style  = "208"

[nodejs]
symbol = " "
style  = "bold green"

[python]
symbol = " "
style  = "bold yellow"

[golang]
symbol = " "
style  = "bold cyan"

[rust]
symbol = " "
style  = "bold red"

[java]
symbol = " "
style  = "bold red"

[terraform]
symbol = "💠 "
style  = "bold purple"

[os]
disabled = false
[os.symbols]
Alpine   = " "
Arch     = " "
CentOS   = " "
Debian   = " "
Fedora   = " "
Linux    = " "
Macos    = " "
NixOS    = " "
Raspbian = " "
Ubuntu   = " "
Windows  = " "

[cmd_duration]
min_time = 2000
format   = "took [$duration](bold yellow) "

[username]
show_always = false
style_user  = "bold yellow"
style_root  = "bold red"
format      = "[$user]($style)@"

[hostname]
ssh_only = true
style    = "bold green"
format   = "[$hostname]($style) "
EOF
}
