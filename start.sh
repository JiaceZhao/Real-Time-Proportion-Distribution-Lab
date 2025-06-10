#!/bin/bash

# =================================
# 一键启动脚本 (One-Click Startup Script)
# Real-Time Proportion Distribution Visualization
# 自动环境配置 + 项目启动
# =================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目信息
PROJECT_NAME="Real-Time Proportion Distribution"
PROJECT_VERSION="1.1.0"
PROJECT_AUTHOR="JiaceZhao"
PROJECT_GITHUB="https://github.com/JiaceZhao/Real-Time-Proportion-Distribution-Lab"

# 打印横幅
print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           📊 Real-Time Proportion Distribution 📊           ║"
    echo "║                    Science Fair Project                      ║"
    echo "║                                                              ║"
    echo "║                🚀 一键环境配置+启动脚本 🚀                    ║"
    echo "║                                                              ║"
    echo "║                    👨‍💻 Author: ${PROJECT_AUTHOR}                     ║"
    echo "║      🔗 ${PROJECT_GITHUB}      ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 打印状态信息
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 打印成功信息
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 打印警告信息
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 打印错误信息
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 打印安装信息
print_install() {
    echo -e "${CYAN}[INSTALL]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_success "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_success "检测到 Linux 系统"
    else
        print_error "不支持的操作系统: $OSTYPE"
        print_error "目前支持 macOS 和 Linux 系统"
        exit 1
    fi
}

# 检查并安装 Homebrew (仅 macOS)
check_and_install_homebrew() {
    if [[ "$OS" != "macos" ]]; then
        return 0
    fi
    
    print_status "检查 Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew 未安装，开始自动安装..."
        print_install "正在下载并安装 Homebrew..."
        
        # 安装 Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [ $? -eq 0 ]; then
            print_success "Homebrew 安装完成！"
            
            # 添加 Homebrew 到 PATH (适用于 Apple Silicon Mac)
            if [[ $(uname -m) == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            print_error "Homebrew 安装失败！"
            print_error "请手动访问 https://brew.sh 安装 Homebrew"
            exit 1
        fi
    else
        BREW_VERSION=$(brew --version | head -n1)
        print_success "Homebrew 已安装: $BREW_VERSION"
    fi
}

# 检查并安装 Node.js
check_and_install_node() {
    print_status "检查 Node.js 环境..."
    
    if ! command -v node &> /dev/null; then
        print_warning "Node.js 未安装，开始自动安装..."
        
        if [[ "$OS" == "macos" ]]; then
            print_install "使用 Homebrew 安装 Node.js..."
            brew install node
        elif [[ "$OS" == "linux" ]]; then
            print_install "使用包管理器安装 Node.js..."
            
            # 检测 Linux 发行版
            if command -v apt-get &> /dev/null; then
                # Debian/Ubuntu
                sudo apt-get update
                sudo apt-get install -y nodejs npm
            elif command -v yum &> /dev/null; then
                # CentOS/RHEL
                sudo yum install -y nodejs npm
            elif command -v dnf &> /dev/null; then
                # Fedora
                sudo dnf install -y nodejs npm
            else
                print_error "无法检测 Linux 包管理器"
                print_error "请手动安装 Node.js: https://nodejs.org"
                exit 1
            fi
        fi
        
        # 验证安装
        if command -v node &> /dev/null; then
            NODE_VERSION=$(node --version)
            print_success "Node.js 安装完成: $NODE_VERSION"
        else
            print_error "Node.js 安装失败！"
            print_error "请手动访问 https://nodejs.org 下载安装"
            exit 1
        fi
    else
        NODE_VERSION=$(node --version)
        print_success "Node.js 已安装: $NODE_VERSION"
    fi
    
    # 检查 Node.js 版本 (推荐 16+)
    NODE_MAJOR_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_MAJOR_VERSION" -lt 16 ]; then
        print_warning "Node.js 版本较旧 ($NODE_VERSION)，推荐使用 16+ 版本"
        print_status "考虑升级 Node.js 以获得更好的性能和兼容性"
    fi
}

# 检查并安装 npm
check_and_install_npm() {
    print_status "检查 npm 环境..."
    
    if ! command -v npm &> /dev/null; then
        print_warning "npm 未安装，开始自动安装..."
        
        if [[ "$OS" == "macos" ]]; then
            print_install "npm 通常随 Node.js 一起安装，尝试重新安装 Node.js..."
            brew reinstall node
        elif [[ "$OS" == "linux" ]]; then
            print_install "安装 npm..."
            
            if command -v apt-get &> /dev/null; then
                sudo apt-get install -y npm
            elif command -v yum &> /dev/null; then
                sudo yum install -y npm
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y npm
            fi
        fi
        
        # 验证安装
        if command -v npm &> /dev/null; then
            NPM_VERSION=$(npm --version)
            print_success "npm 安装完成: v$NPM_VERSION"
        else
            print_error "npm 安装失败！"
            exit 1
        fi
    else
        NPM_VERSION=$(npm --version)
        print_success "npm 已安装: v$NPM_VERSION"
    fi
}

# 优化 npm 配置
optimize_npm() {
    print_status "优化 npm 配置..."
    
    # 设置 npm 镜像源（国内用户）
    if [[ "$LANG" =~ zh_CN ]] || [[ "$LC_ALL" =~ zh_CN ]]; then
        print_status "检测到中文环境，设置国内镜像源..."
        npm config set registry https://registry.npmmirror.com
        print_success "已设置淘宝镜像源，提升下载速度"
    fi
    
    # 设置 npm 缓存目录
    npm config set cache ~/.npm-cache
    
    # 更新 npm 到最新版本
    print_status "更新 npm 到最新版本..."
    npm install -g npm@latest
    
    if [ $? -eq 0 ]; then
        NEW_NPM_VERSION=$(npm --version)
        print_success "npm 已更新到最新版本: v$NEW_NPM_VERSION"
    fi
}

# 检查项目依赖
check_dependencies() {
    print_status "检查项目依赖..."
    
    if [ ! -d "node_modules" ] || [ ! -f "node_modules/.package-lock.json" ]; then
        print_warning "项目依赖未安装，开始安装..."
        install_dependencies
    else
        # 检查 package.json 是否有更新
        if [ "package.json" -nt "node_modules/.package-lock.json" ]; then
            print_warning "检测到 package.json 更新，重新安装依赖..."
            install_dependencies
        else
            print_success "项目依赖已安装且为最新版本"
        fi
    fi
}

# 安装项目依赖
install_dependencies() {
    print_install "正在安装项目依赖..."
    echo -e "${CYAN}"
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│  📦 安装中... 这可能需要几分钟时间                          │"
    echo "│  🌐 如果下载较慢，脚本已自动配置国内镜像源                  │"
    echo "│  ☕ 请耐心等待，安装完成后会自动启动项目                    │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
    
    # 清理缓存和旧的安装
    rm -rf node_modules package-lock.json
    npm cache clean --force
    
    # 安装依赖
    npm install
    
    if [ $? -eq 0 ]; then
        print_success "项目依赖安装完成！"
        
        # 创建标记文件
        touch node_modules/.package-lock.json
        
        # 显示安装的关键依赖
        print_status "已安装的关键依赖："
        echo -e "  • Vue.js 3.x - 前端框架"
        echo -e "  • Vite - 构建工具"
        echo -e "  • Chart.js - 图表库"
        echo -e "  • Tailwind CSS - 样式框架"
        echo -e "  • XLSX - Excel导出功能"
        echo -e "  • File-saver - 文件下载功能"
    else
        print_error "依赖安装失败！"
        print_error "请检查网络连接或手动运行 'npm install'"
        exit 1
    fi
}

# 检查端口是否被占用
check_port() {
    local port=${1:-3000}
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "端口 $port 已被占用"
        print_status "Vite 将自动选择其他可用端口..."
    else
        print_success "端口 $port 可用"
    fi
}

# 环境诊断和修复
diagnose_environment() {
    print_status "运行环境诊断..."
    
    # 检查磁盘空间
    if [[ "$OS" == "macos" ]]; then
        DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
    else
        DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
    fi
    
    if [ "$DISK_USAGE" -gt 90 ]; then
        print_warning "磁盘空间不足 (已使用 ${DISK_USAGE}%)，可能影响安装"
    else
        print_success "磁盘空间充足 (已使用 ${DISK_USAGE}%)"
    fi
    
    # 检查内存
    if [[ "$OS" == "macos" ]]; then
        MEMORY_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    else
        MEMORY_GB=$(free -g | awk 'NR==2{print $2}')
    fi
    
    if [ "$MEMORY_GB" -lt 4 ]; then
        print_warning "系统内存较少 (${MEMORY_GB}GB)，建议关闭其他应用程序"
    else
        print_success "系统内存充足 (${MEMORY_GB}GB)"
    fi
    
    # 检查网络连接
    print_status "检查网络连接..."
    if ping -c 1 google.com >/dev/null 2>&1; then
        print_success "网络连接正常"
    elif ping -c 1 baidu.com >/dev/null 2>&1; then
        print_success "网络连接正常 (国内网络)"
    else
        print_warning "网络连接异常，可能影响依赖下载"
    fi
}

# 启动开发服务器
start_dev_server() {
    print_status "启动开发服务器..."
    echo -e "${CYAN}"
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│  🎯 开发服务器即将启动...                                   │"
    echo "│  📱 应用将在浏览器中自动打开                                │"
    echo "│  🔄 文件变更将自动热重载                                   │"
    echo "│  ⏹️  按 Ctrl+C 停止服务器                                  │"
    echo "│                                                             │"
    echo "│  🌟 新功能: 数据管理和Excel导出                            │"
    echo "│  📊 支持数据保存、历史记录和一键导出                        │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
    
    sleep 2
    
    # 启动 Vite 开发服务器
    npm run dev
}

# 显示帮助信息
show_help() {
    echo -e "${PURPLE}使用方法:${NC}"
    echo "  $0                 # 一键环境配置并启动项目"
    echo "  $0 --help          # 显示此帮助信息"
    echo "  $0 --check         # 仅检查环境，不启动项目"
    echo "  $0 --update        # 更新依赖并启动项目"
    echo ""
    echo -e "${PURPLE}支持的系统:${NC}"
    echo "  • macOS (推荐使用 Homebrew)"
    echo "  • Linux (Ubuntu/Debian/CentOS/Fedora)"
    echo ""
    echo -e "${PURPLE}自动安装的环境:${NC}"
    echo "  • Homebrew (仅 macOS)"
    echo "  • Node.js (版本 16+)"
    echo "  • npm (最新版本)"
    echo "  • 项目依赖 (Vue.js, Vite, Chart.js 等)"
}

# 主函数
main() {
    # 解析命令行参数
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --check)
            CHECK_ONLY=true
            ;;
        --update)
            UPDATE_MODE=true
            ;;
    esac
    
    print_banner
    
    # 检查当前目录是否为项目根目录
    if [ ! -f "package.json" ]; then
        print_error "未找到 package.json 文件！"
        print_error "请确保在项目根目录下运行此脚本"
        exit 1
    fi
    
    print_status "开始一键环境配置和启动流程..."
    echo
    
    # 系统环境检测和配置
    detect_os
    diagnose_environment
    echo
    
    # 安装开发环境
    print_status "=== 第一步: 配置开发环境 ==="
    check_and_install_homebrew
    check_and_install_node
    check_and_install_npm
    optimize_npm
    echo
    
    # 项目依赖管理
    print_status "=== 第二步: 安装项目依赖 ==="
    if [[ "$UPDATE_MODE" == "true" ]]; then
        print_status "强制更新模式，重新安装所有依赖..."
        install_dependencies
    else
        check_dependencies
    fi
    echo
    
    # 端口检查
    print_status "=== 第三步: 环境检查 ==="
    check_port 3000
    echo
    
    print_success "🎉 环境配置完成！准备启动应用..."
    echo
    
    # 显示项目信息
    echo -e "${PURPLE}项目信息:${NC}"
    echo -e "  📦 名称: ${PROJECT_NAME}"
    echo -e "  🏷️  版本: ${PROJECT_VERSION}"
    echo -e "  👨‍💻 作者: ${PROJECT_AUTHOR}"
    echo -e "  🔗 仓库: ${PROJECT_GITHUB}"
    echo -e "  🛠️  框架: Vue.js 3 + Vite"
    echo -e "  🎨 样式: Tailwind CSS"
    echo -e "  📊 图表: Chart.js"
    echo -e "  💾 新功能: 数据管理和Excel导出"
    echo -e "  🌐 访问地址: http://localhost:3000 (或自动分配的端口)"
    echo
    
    # 仅检查模式
    if [[ "$CHECK_ONLY" == "true" ]]; then
        print_success "环境检查完成，所有依赖已就绪！"
        print_status "运行 './start.sh' 启动开发服务器"
        exit 0
    fi
    
    # 启动服务器
    print_status "=== 第四步: 启动应用 ==="
    start_dev_server
}

# 错误处理
trap 'echo -e "\n${RED}[ERROR]${NC} 启动过程被中断"; exit 1' INT

# 运行主函数
main "$@" 