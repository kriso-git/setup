#!/bin/bash
# Kriso · Laptop Setup Script (macOS)
# Futtatás: curl -fsSL https://raw.githubusercontent.com/kriso-git/setup/main/setup.sh -o ~/setup.sh && chmod +x ~/setup.sh && bash ~/setup.sh

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

TOTAL=10
STEP=0

bar() {
  STEP=$((STEP + 1))
  local filled=$((STEP * 24 / TOTAL))
  local empty=$((24 - filled))
  local b=""
  for ((i=0; i<filled; i++)); do b+="█"; done
  for ((i=0; i<empty; i++)); do b+="░"; done
  echo ""
  echo -e "${CYAN}  [${b}] ${STEP}/${TOTAL}${NC}  ${BOLD}$1${NC}"
}

ok()   { echo -e "  ${GREEN}✓${NC}  $1"; }
skip() { echo -e "  ${DIM}–  $1${NC}"; }
run()  { echo -e "  ${CYAN}▸${NC}  $1"; }

# ── Header ───────────────────────────────────────────────────
clear
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ██╗  ██╗██████╗ ██╗███████╗ ██████╗      "
echo "  ██║ ██╔╝██╔══██╗██║██╔════╝██╔═══██╗     "
echo "  █████╔╝ ██████╔╝██║███████╗██║   ██║     "
echo "  ██╔═██╗ ██╔══██╗██║╚════██║██║   ██║     "
echo "  ██║  ██╗██║  ██║██║███████║╚██████╔╝     "
echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝ ╚═════╝     "
echo -e "${NC}"
echo -e "  ${DIM}LAPTOP SETUP · MACOS${NC}"
echo -e "  ${DIM}────────────────────────────────────────${NC}"
sleep 0.4

# ── 1. Homebrew ──────────────────────────────────────────────
bar "Homebrew"
if ! command -v brew &>/dev/null; then
  run "Telepítés..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" && \
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  ok "Homebrew telepítve"
else
  skip "Homebrew $(brew --version | head -1) — megvan"
fi

# ── 2. Node.js ───────────────────────────────────────────────
bar "Node.js"
if ! command -v node &>/dev/null; then
  run "Telepítés..."
  brew install node --quiet
  ok "Node.js telepítve: $(node -v)"
else
  skip "Node.js $(node -v) — megvan"
fi

# ── 3. Git ───────────────────────────────────────────────────
bar "Git"
if ! command -v git &>/dev/null; then
  run "Telepítés..."
  brew install git --quiet
  ok "Git telepítve"
else
  skip "Git $(git --version | awk '{print $3}') — megvan"
fi

# ── 4. Vercel CLI ────────────────────────────────────────────
bar "Vercel CLI"
if ! command -v vercel &>/dev/null; then
  run "Telepítés..."
  npm install -g vercel --silent
  ok "Vercel CLI telepítve"
else
  skip "Vercel CLI $(vercel --version 2>/dev/null | head -1) — megvan"
fi

# ── 5. Munkamappa ────────────────────────────────────────────
bar "Munkamappa"
WORK="$HOME/Website Biz"
mkdir -p "$WORK"
ok "Mappa: $WORK"

# ── 6. Projektek klónozása / frissítése ─────────────────────
bar "Projektek"

sync_repo() {
  local repo=$1 dir=$2
  if [[ -d "$WORK/$dir/.git" ]]; then
    run "$dir frissítése..."
    git -C "$WORK/$dir" pull --quiet
    ok "$dir — naprakész"
  else
    run "$dir letöltése..."
    git clone "https://github.com/kriso-git/$repo.git" "$WORK/$dir" --quiet
    ok "$dir — letöltve"
  fi
}

sync_repo "DonnaPizzaKecskemet" "donna-pizza"
sync_repo "alexoldal"           "alexoldal"
sync_repo "fexyke-terminal"     "f3xykee-terminal"

# ── 7. npm install ───────────────────────────────────────────
bar "npm csomagok"

install_deps() {
  local dir=$1
  if [[ -d "$WORK/$dir/node_modules" ]]; then
    skip "$dir — csomagok már megvannak"
  else
    run "$dir..."
    npm install --prefix "$WORK/$dir" --silent
    ok "$dir — csomagok kész"
  fi
}

install_deps "donna-pizza"
install_deps "alexoldal"
install_deps "f3xykee-terminal"

# ── 8. Claude Code skills ────────────────────────────────────
bar "Claude Code skillек"

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

sync_skill() {
  local repo=$1 name=$2
  if [[ -d "$SKILLS_DIR/$name/.git" ]]; then
    git -C "$SKILLS_DIR/$name" pull --quiet
    skip "$name — naprakész"
  else
    run "$name letöltése..."
    git clone "https://github.com/$repo.git" "$SKILLS_DIR/$name" --quiet
    ok "$name — kész"
  fi
}

sync_skill "pbakaus/impeccable"                    "impeccable"
sync_skill "nextlevelbuilder/ui-ux-pro-max-skill"  "ui-ux-pro-max-skill"
sync_skill "amaancoderx/npxskillui"                "npxskillui"
sync_skill "dgreenheck/webgpu-claude-skill"        "webgpu-claude-skill"
sync_skill "VoltAgent/awesome-design-md"           "awesome-design-md"

# ── 9. Claude Code settings.json ────────────────────────────
bar "Claude Code beállítások"

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
  skip "settings.json — már megvan"
else
  mkdir -p "$HOME/.claude"
  cat > "$CLAUDE_SETTINGS" << 'EOF'
{
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true,
    "frontend-design@claude-code-plugins": true
  },
  "extraKnownMarketplaces": {
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    },
    "claude-code-plugins": {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-code"
      }
    },
    "anthropic-agent-skills": {
      "source": {
        "source": "github",
        "repo": "anthropics/skills"
      }
    }
  },
  "effortLevel": "high"
}
EOF
  ok "settings.json létrehozva"
fi

# ── 10. f3xykee .env.local ───────────────────────────────────
bar "f3xykee környezeti változók"
cd "$WORK/f3xykee-terminal"

if [[ -f ".env.local" ]]; then
  skip ".env.local — már megvan"
else
  echo ""
  echo -e "  ${YELLOW}!${NC}  Vercel bejelentkezés szükséges."
  echo -e "  ${DIM}   Böngésző nyílik — jelentkezz be, majd gyere vissza ide.${NC}"
  echo ""
  vercel login
  echo ""
  run "Projekt összekapcsolása..."
  vercel link --yes
  run "Kulcsok letöltése..."
  vercel env pull .env.local
  ok ".env.local letöltve"
fi

# ── Kész ─────────────────────────────────────────────────────
echo ""
echo -e "  ${DIM}────────────────────────────────────────${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}✓ MINDEN KÉSZ!${NC}"
echo ""
echo -e "  ${DIM}Projektek indítása:${NC}"
echo ""
echo -e "  ${CYAN}donna-pizza${NC}       cd ~/Website\ Biz/donna-pizza && npm run dev"
echo -e "  ${CYAN}alexoldal${NC}         cd ~/Website\ Biz/alexoldal && npm run dev"
echo -e "  ${CYAN}f3xykee-terminal${NC}  cd ~/Website\ Biz/f3xykee-terminal && npm run dev"
echo ""
echo -e "  ${DIM}Claude Code pluginok aktiválásához:${NC}"
echo -e "  ${DIM}Írd be a chatbe: /plugin install superpowers@superpowers-marketplace${NC}"
echo ""
