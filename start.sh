#!/bin/bash

# =================================
# 一键启动脚本 (One-Click Startup Script)
# Real-Time Proportion Distribution Visualization
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

# 打印横幅
print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           📊 Real-Time Proportion Distribution 📊           ║"
    echo "║                    Science Fair Project                      ║"
    echo "║                                                              ║"
    echo "║                    🚀 一键启动脚本 🚀                        ║"
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

# 检查Node.js是否安装
check_node() {
    print_status "检查 Node.js 环境..."
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js 未安装！请先安装 Node.js (推荐版本 18+)"
        echo -e "${CYAN}访问 https://nodejs.org 下载安装${NC}"
        exit 1
    fi
    
    NODE_VERSION=$(node --version)
    print_success "Node.js 已安装: $NODE_VERSION"
}

# 检查npm是否安装
check_npm() {
    print_status "检查 npm 环境..."
    
    if ! command -v npm &> /dev/null; then
        print_error "npm 未安装！"
        exit 1
    fi
    
    NPM_VERSION=$(npm --version)
    print_success "npm 已安装: v$NPM_VERSION"
}

# 检查依赖
check_dependencies() {
    print_status "检查项目依赖..."
    
    if [ ! -d "node_modules" ]; then
        print_warning "依赖未安装，开始安装依赖..."
        install_dependencies
    else
        print_success "依赖已安装"
    fi
}

# 安装依赖
install_dependencies() {
    print_status "正在安装项目依赖... (这可能需要几分钟)"
    
    if npm install; then
        print_success "依赖安装完成！"
    else
        print_error "依赖安装失败！"
        exit 1
    fi
}

# 检查端口是否被占用
check_port() {
    local port=${1:-5173}
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        print_warning "端口 $port 已被占用"
        print_status "将尝试使用其他可用端口..."
    else
        print_success "端口 $port 可用"
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
    echo "└─────────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
    
    sleep 2
    
    # 启动 Vite 开发服务器
    npm run dev
}

# 主函数
main() {
    print_banner
    
    # 检查当前目录是否为项目根目录
    if [ ! -f "package.json" ]; then
        print_error "未找到 package.json 文件！"
        print_error "请确保在项目根目录下运行此脚本"
        exit 1
    fi
    
    print_status "开始一键启动流程..."
    echo
    
    # 执行检查和启动步骤
    check_node
    check_npm
    check_dependencies
    check_port 5173
    
    echo
    print_success "环境检查完成！准备启动应用..."
    echo
    
    # 显示项目信息
    echo -e "${PURPLE}项目信息:${NC}"
    echo -e "  📦 名称: ${PROJECT_NAME}"
    echo -e "  🏷️  版本: ${PROJECT_VERSION}"
    echo -e "  🛠️  框架: Vue.js 3 + Vite"
    echo -e "  🎨 样式: Tailwind CSS"
    echo -e "  📊 图表: Chart.js"
    echo -e "  💾 新功能: 数据管理和Excel导出"
    echo -e "  🔗 访问地址: http://localhost:3000"
    echo
    
    # 启动服务器
    start_dev_server
}

# 错误处理
trap 'echo -e "\n${RED}[ERROR]${NC} 启动过程被中断"; exit 1' INT

# 运行主函数
main "$@" 