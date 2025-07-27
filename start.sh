#!/bin/bash

# 🚀 Blog Microservice Quick Start Script
# This script will start all services for the blog microservice

set -e  # Exit on any error

echo "🚀 Starting Blog Microservice..."
echo "================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Python
if ! command -v python &> /dev/null; then
    print_error "Python is not installed. Please install Python 3.13+"
    exit 1
fi

PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
if (( $(echo "$PYTHON_VERSION < 3.13" | bc -l) )); then
    print_warning "Python version is $PYTHON_VERSION. Recommended: 3.13+"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 18+"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if (( NODE_VERSION < 18 )); then
    print_warning "Node.js version is v$NODE_VERSION. Recommended: v18+"
fi

# Check uv
if ! command -v uv &> /dev/null; then
    print_info "Installing uv package manager..."
    pip install uv
fi

print_status "Prerequisites check completed"

# Function to setup and start blog service
start_blog_service() {
    print_info "Setting up Blog Service (Port 8000)..."
    
    cd server/blog
    
    # Install dependencies
    print_info "Installing blog service dependencies..."
    uv sync
    
    # Run migrations
    print_info "Running blog database migrations..."
    uv run python manage.py migrate
    
    # Generate sample data if needed
    if [ ! -f "data_generated.flag" ]; then
        print_info "Generating sample articles..."
        uv run python manage.py generate_articles
        touch data_generated.flag
    fi
    
    # Start the service in background
    print_info "Starting blog service on port 8000..."
    uv run python manage.py runserver 8000 &
    BLOG_PID=$!
    echo $BLOG_PID > blog_service.pid
    
    cd ../..
    print_status "Blog service started (PID: $BLOG_PID)"
}

# Function to setup and start comments service
start_comments_service() {
    print_info "Setting up Comments Service (Port 8001)..."
    
    cd server/comments
    
    # Install dependencies
    print_info "Installing comments service dependencies..."
    uv sync
    
    # Run migrations
    print_info "Running comments database migrations..."
    uv run python manage.py migrate
    
    # Generate sample data if needed
    if [ ! -f "data_generated.flag" ]; then
        print_info "Generating sample comments..."
        uv run python manage.py generate_comments
        touch data_generated.flag
    fi
    
    # Start the service in background
    print_info "Starting comments service on port 8001..."
    uv run python manage.py runserver 8001 &
    COMMENTS_PID=$!
    echo $COMMENTS_PID > comments_service.pid
    
    cd ../..
    print_status "Comments service started (PID: $COMMENTS_PID)"
}

# Function to setup and start frontend
start_frontend() {
    print_info "Setting up Frontend (Port 3000)..."
    
    cd client
    
    # Install dependencies
    print_info "Installing frontend dependencies..."
    npm install
    
    # Create environment file if it doesn't exist
    if [ ! -f ".env.local" ]; then
        print_info "Creating .env.local file..."
        cat > .env.local << EOL
NEXT_PUBLIC_BLOG_API_BASE_URL=http://localhost:8000
NEXT_PUBLIC_COMMENTS_API_BASE_URL=http://localhost:8001
EOL
    fi
    
    # Start the frontend in background
    print_info "Starting frontend on port 3000..."
    npm run dev &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > frontend.pid
    
    cd ..
    print_status "Frontend started (PID: $FRONTEND_PID)"
}

# Function to wait for services to be ready
wait_for_services() {
    print_info "Waiting for services to be ready..."
    
    # Wait for blog service
    print_info "Checking blog service..."
    for i in {1..30}; do
        if curl -s http://localhost:8000/api/v1/articles/ > /dev/null 2>&1; then
            print_status "Blog service is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "Blog service failed to start"
            exit 1
        fi
        sleep 2
    done
    
    # Wait for comments service
    print_info "Checking comments service..."
    for i in {1..30}; do
        if curl -s http://localhost:8001/api/v1/articles/1/comments/ > /dev/null 2>&1; then
            print_status "Comments service is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "Comments service failed to start"
            exit 1
        fi
        sleep 2
    done
    
    # Wait for frontend
    print_info "Checking frontend..."
    for i in {1..30}; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            print_status "Frontend is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "Frontend failed to start"
            exit 1
        fi
        sleep 2
    done
}

# Cleanup function
cleanup() {
    print_info "Shutting down services..."
    
    # Kill background processes
    if [ -f "server/blog/blog_service.pid" ]; then
        kill $(cat server/blog/blog_service.pid) 2>/dev/null || true
        rm server/blog/blog_service.pid
    fi
    
    if [ -f "server/comments/comments_service.pid" ]; then
        kill $(cat server/comments/comments_service.pid) 2>/dev/null || true
        rm server/comments/comments_service.pid
    fi
    
    if [ -f "client/frontend.pid" ]; then
        kill $(cat client/frontend.pid) 2>/dev/null || true
        rm client/frontend.pid
    fi
    
    # Kill any remaining processes on our ports
    lsof -ti:8000 | xargs kill -9 2>/dev/null || true
    lsof -ti:8001 | xargs kill -9 2>/dev/null || true
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true
    
    print_status "All services stopped"
}

# Trap cleanup function on script exit
trap cleanup EXIT INT TERM

# Main execution
echo "🏗️  Starting all services..."

# Start services
start_blog_service
sleep 3

start_comments_service
sleep 3

start_frontend
sleep 5

# Wait for all services to be ready
wait_for_services

echo ""
echo "🎉 All services are now running!"
echo "=================================="
echo ""
echo "📊 Service URLs:"
echo "   • Frontend:        http://localhost:3000"
echo "   • Blog API:        http://localhost:8000/api/v1/articles/"
echo "   • Comments API:    http://localhost:8001/api/v1/articles/{id}/comments/"
echo ""
echo "🔧 Admin Interfaces:"
echo "   • Blog Admin:      http://localhost:8000/admin/"
echo "   • Comments Admin:  http://localhost:8001/admin/"
echo ""
echo "📝 API Documentation:"
echo "   • Blog API:        http://localhost:8000/api/v1/"
echo "   • Comments API:    http://localhost:8001/api/v1/"
echo ""
echo "⚡ Quick Test:"
echo "   curl http://localhost:8000/api/v1/articles/"
echo ""
echo "🛑 To stop all services, press Ctrl+C"
echo ""

# Keep script running
while true; do
    sleep 1
done
