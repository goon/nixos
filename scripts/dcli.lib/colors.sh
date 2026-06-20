RE='\033[0;31m'
GR='\033[0;32m'
YE='\033[0;33m'
BL='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BL}[INFO]${NC} $1"; }
success() { echo -e "${GR}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YE}[WARN]${NC} $1"; }
error() { echo -e "${RE}[ERROR]${NC} $1"; exit 1; }
