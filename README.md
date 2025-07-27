# 📚 Blog Microservice Documentation

## 🏗️ Architecture Overview

This is a complete blog microservice system built with a **Django REST Framework** backend and **Next.js** frontend. The system consists of three main components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Blog Service  │    │ Comments Service│    │  Frontend App   │
│  (Port: 8000)   │    │  (Port: 8001)   │    │  (Port: 3000)   │
│                 │    │                 │    │                 │
│ • Articles CRUD │    │ • Comments CRUD │    │ • Article Grid  │
│ • Factory Data  │    │ • Factory Data  │    │ • Article Detail│
│ • REST API      │    │ • REST API      │    │ • Comment UI    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                        │                        │
        └────────────────────────┼────────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Database Layer │
                    │                 │
                    │ • SQLite (Dev)  │
                    │ • Independent   │
                    │   Databases     │
                    └─────────────────┘
```

## 🎯 System Components

### 1. **Blog Service** (Django)
- **Purpose**: Manages articles/blog posts
- **Port**: 8000
- **Database**: `blog/db.sqlite3`
- **API Endpoints**: `/api/v1/articles/`

### 2. **Comments Service** (Django)
- **Purpose**: Manages comments for articles
- **Port**: 8001
- **Database**: `comments/db.sqlite3`
- **API Endpoints**: `/api/v1/articles/{id}/comments/`

### 3. **Frontend Client** (Next.js)
- **Purpose**: User interface for browsing articles and managing comments
- **Port**: 3000
- **Features**: Responsive design, real-time updates, shadcn/ui components

## 📋 Prerequisites

Before running the microservice, ensure you have:

- **Python 3.13+** installed
- **Node.js 18+** and **npm** installed
- **uv** package manager installed (`pip install uv`)
- **Git** (for cloning if needed)

### Quick Prerequisites Check
```bash
# Check Python version
python --version  # Should be 3.13+

# Check Node.js version
node --version   # Should be 18+

# Check if uv is installed
uv --version

# Install uv if not available
pip install uv
```

## 🚀 Quick Start Guide

### 1. **Clone and Setup**
```bash
# Clone the repository (if from git)
git clone <repository-url>
cd blog-microservice

# Or navigate to your existing directory
cd /path/to/blog-microservice
```

### 2. **Backend Setup - Blog Service**
```bash
# Navigate to blog service
cd server/blog

# Install dependencies with uv
uv sync

# Run database migrations
uv run python manage.py migrate

# Generate sample data (100 articles)
uv run python manage.py generate_articles

# Start the blog service
uv run python manage.py runserver 8000
```

**✅ Blog Service should now be running at:** `http://localhost:8000`

### 3. **Backend Setup - Comments Service**
```bash
# Open a new terminal window
cd server/comments

# Install dependencies with uv
uv sync

# Run database migrations
uv run python manage.py migrate

# Generate sample comments (for articles 1-101)
uv run python manage.py generate_comments

# Start the comments service
uv run python manage.py runserver 8001
```

**✅ Comments Service should now be running at:** `http://localhost:8001`

### 4. **Frontend Setup**
```bash
# Open a third terminal window
cd client

# Install dependencies
npm install

# Start the development server
npm run dev
```

**✅ Frontend should now be running at:** `http://localhost:3000`

## 🔧 Development Setup (Detailed)

### **Backend Services Configuration**

#### **Environment Variables**
Create `.env` files in each service directory if needed:

**`server/blog/.env`**
```env
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

**`server/comments/.env`**
```env
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

#### **Database Setup**

Both services use SQLite by default. For production, you might want to use PostgreSQL:

```python
# In settings.py for production
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'blog_db',
        'USER': 'your_user',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

### **Frontend Configuration**

#### **Environment Variables**
Create **`client/.env.local`**:
```env
NEXT_PUBLIC_BLOG_API_BASE_URL=http://localhost:8000
NEXT_PUBLIC_COMMENTS_API_BASE_URL=http://localhost:8001
```

## 📊 API Documentation

### **Blog Service API** (`http://localhost:8000`)

#### **Get All Articles**
```http
GET /api/v1/articles/
```
**Response:**
```json
[
  {
    "id": 1,
    "title": "Sample Article Title",
    "content": "Article content here...",
    "created_at": "2025-01-26T10:00:00Z",
    "updated_at": "2025-01-26T10:00:00Z"
  }
]
```

#### **Get Single Article**
```http
GET /api/v1/articles/{id}/
```

#### **Create Article**
```http
POST /api/v1/articles/
Content-Type: application/json

{
  "title": "New Article Title",
  "content": "Article content..."
}
```

### **Comments Service API** (`http://localhost:8001`)

#### **Get Comments for Article**
```http
GET /api/v1/articles/{article_id}/comments/
```
**Response:**
```json
[
  {
    "id": 1,
    "article_id": 1,
    "author_name": "John Doe",
    "author_email": "john@example.com",
    "content": "Great article!",
    "is_approved": true,
    "created_at": "2025-01-26T10:00:00Z",
    "updated_at": "2025-01-26T10:00:00Z"
  }
]
```

#### **Create Comment**
```http
POST /api/v1/articles/{article_id}/comments/
Content-Type: application/json

{
  "author_name": "Jane Smith",
  "author_email": "jane@example.com",
  "content": "Thanks for sharing this!",
  "is_approved": true
}
```

## 🎨 Frontend Features

### **Components Overview**

1. **ArticleGrid** - Displays all articles in a responsive grid
2. **ArticleCard** - Individual article preview with comment count
3. **ArticleDetail** - Full article view with comments
4. **CommentsSection** - Displays all comments for an article
5. **AddComment** - Form for adding new comments

### **Navigation Flow**
```
Homepage (/) 
    ↓
Article Grid (/blogs)
    ↓
Article Detail (/blogs/[id])
    ↓
Add Comment (inline form)
```

### **UI Component Library**
- **shadcn/ui** - Modern component library
- **Tailwind CSS** - Utility-first styling
- **Lucide Icons** - Beautiful icon set
- **Responsive Design** - Mobile-first approach

## 🛠️ Development Commands

### **Backend Commands**

#### **Blog Service**
```bash
cd server/blog

# Start development server
uv run python manage.py runserver 8000

# Create superuser
uv run python manage.py createsuperuser

# Run migrations
uv run python manage.py migrate

# Generate sample data
uv run python manage.py generate_articles

# Django shell
uv run python manage.py shell

# Collect static files (production)
uv run python manage.py collectstatic
```

#### **Comments Service**
```bash
cd server/comments

# Start development server
uv run python manage.py runserver 8001

# Create superuser
uv run python manage.py createsuperuser

# Run migrations
uv run python manage.py migrate

# Generate sample comments
uv run python manage.py generate_comments

# Django shell
uv run python manage.py shell
```

### **Frontend Commands**
```bash
cd client

# Development server
npm run dev

# Production build
npm run build

# Start production server
npm run start

# Lint code
npm run lint

# Install new dependencies
npm install <package-name>

# Add shadcn/ui component
npx shadcn@latest add <component-name>
```

## 🧪 Testing

### **Backend Testing**
```bash
# Test blog service
cd server/blog
uv run python manage.py test

# Test comments service
cd server/comments
uv run python manage.py test

# Test with coverage
uv run python -m pytest --cov=.
```

### **Frontend Testing**
```bash
cd client

# Run tests (if configured)
npm test

# Type checking (if TypeScript)
npm run type-check
```

## 📁 Project Structure

```
blog-microservice/
├── README.md                          # This documentation
├── server/                            # Backend services
│   ├── blog/                         # Blog service (Port 8000)
│   │   ├── blog/                     # Django app
│   │   │   ├── __init__.py
│   │   │   ├── models.py            # Article model
│   │   │   ├── serializers.py       # API serializers
│   │   │   ├── views.py             # API views
│   │   │   ├── urls.py              # URL routing
│   │   │   └── settings.py          # Django settings
│   │   ├── manage.py                # Django management
│   │   ├── pyproject.toml           # Python dependencies
│   │   ├── uv.lock                  # Locked dependencies
│   │   └── db.sqlite3               # SQLite database
│   │
│   ├── comments/                     # Comments service (Port 8001)
│   │   ├── comment/                  # Django app
│   │   │   ├── __init__.py
│   │   │   ├── models.py            # Comment model
│   │   │   ├── serializers.py       # API serializers
│   │   │   ├── views.py             # API views
│   │   │   └── factories.py         # Factory Boy data generation
│   │   ├── comments/                 # Project settings
│   │   │   ├── settings.py          # Django settings
│   │   │   ├── urls.py              # URL routing
│   │   │   └── wsgi.py              # WSGI application
│   │   ├── manage.py                # Django management
│   │   ├── pyproject.toml           # Python dependencies
│   │   ├── uv.lock                  # Locked dependencies
│   │   └── db.sqlite3               # SQLite database
│   │
│   └── query-service/                # Future query service
│
├── client/                           # Frontend application (Port 3000)
│   ├── src/
│   │   ├── app/                     # Next.js app directory
│   │   │   ├── blogs/               # Blog-related pages
│   │   │   │   ├── [id]/            # Dynamic article pages
│   │   │   │   │   └── page.js      # Article detail page
│   │   │   │   └── page.js          # Articles listing page
│   │   │   ├── globals.css          # Global styles
│   │   │   ├── layout.js            # Root layout
│   │   │   └── page.js              # Homepage
│   │   │
│   │   ├── components/              # React components
│   │   │   ├── ui/                  # shadcn/ui components
│   │   │   ├── ArticleCard.jsx      # Article preview card
│   │   │   ├── ArticleGrid.jsx      # Articles grid layout
│   │   │   ├── CommentsSection.jsx  # Comments display
│   │   │   └── AddComment.jsx       # Comment form
│   │   │
│   │   └── lib/                     # Utility functions
│   │       ├── api.js               # API integration
│   │       └── utils.js             # Helper functions
│   │
│   ├── package.json                 # Node.js dependencies
│   ├── package-lock.json            # Locked dependencies
│   ├── tailwind.config.js           # Tailwind configuration
│   ├── components.json              # shadcn/ui configuration
│   └── next.config.js               # Next.js configuration
```

## 🔍 Troubleshooting

### **Common Issues**

#### **Backend Issues**

**Problem**: `Port already in use`
```bash
# Find process using port
lsof -i :8000  # or :8001

# Kill process
kill -9 <PID>
```

**Problem**: `CORS errors`
```python
# Ensure CORS is configured in settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]
```

**Problem**: `Database migration errors`
```bash
# Reset migrations
rm -rf */migrations/0*.py
uv run python manage.py makemigrations
uv run python manage.py migrate
```

#### **Frontend Issues**

**Problem**: `API connection refused`
- Ensure backend services are running
- Check API URLs in `.env.local`
- Verify CORS configuration

**Problem**: `Module not found`
```bash
# Clear node modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Problem**: `Build errors`
```bash
# Clear Next.js cache
rm -rf .next
npm run build
```

### **Performance Optimization**

#### **Backend**
- Use database indexes for frequently queried fields
- Implement caching with Redis
- Use database connection pooling
- Optimize QuerySets with `select_related` and `prefetch_related`

#### **Frontend**
- Use Next.js Image optimization
- Implement lazy loading for components
- Add loading states and skeleton screens
- Use React.memo for expensive components

## 🚀 Production Deployment

### **Backend Deployment**

#### **Docker Setup**
Create `Dockerfile` for each service:

```dockerfile
# Dockerfile for blog service
FROM python:3.13-slim

WORKDIR /app
COPY . .

RUN pip install uv
RUN uv sync

EXPOSE 8000
CMD ["uv", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
```

#### **Environment Variables**
```env
DEBUG=False
SECRET_KEY=your-production-secret-key
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
DATABASE_URL=postgresql://user:pass@host:port/dbname
```

### **Frontend Deployment**

#### **Vercel/Netlify**
```bash
# Build for production
npm run build

# Test production build locally
npm run start
```

#### **Environment Variables**
```env
NEXT_PUBLIC_BLOG_API_BASE_URL=https://api.yourdomain.com
NEXT_PUBLIC_COMMENTS_API_BASE_URL=https://comments-api.yourdomain.com
```

## 📈 Monitoring and Logging

### **Backend Logging**
```python
# In settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': 'debug.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
```

### **Frontend Monitoring**
- Use Sentry for error tracking
- Implement analytics with Google Analytics
- Monitor Core Web Vitals

## 🤝 Contributing

### **Development Workflow**
1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run linting and tests
5. Submit a pull request

### **Code Standards**
- **Backend**: Follow PEP 8 for Python
- **Frontend**: Use Prettier and ESLint
- **Commits**: Use conventional commit messages

## 📝 License

This project is licensed under the MIT License.

---

## 🎉 Getting Help

- **Documentation**: This README file
- **Issues**: Create GitHub issues for bugs
- **Discussions**: Use GitHub discussions for questions

**Happy coding! 🚀**
