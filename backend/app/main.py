from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config.settings import settings

from app.routes.ai_routes import router as ai_router
from app.routes.auth_routes import router as auth_router
from app.routes.citizen_routes import router as citizen_router
from app.routes.officer_routes import router as officer_router
from app.routes.workflow_routes import router as workflow_router
from app.routes.application_routes import router as application_router
from app.routes.audit_routes import router as audit_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=(
        "TrackGov AI Backend - Government Application "
        "Tracking and Workflow Simulation API"
    )
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "https://trackgovai.web.app",
        "https://trackgovai.firebaseapp.com",
        "https://trackgovai-b3dfd.web.app",
        "https://trackgovai-b3dfd.firebaseapp.com",
    ],
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(
    auth_router,
    prefix=settings.API_V1_PREFIX
)

app.include_router(
    citizen_router,
    prefix=settings.API_V1_PREFIX
)

app.include_router(
    officer_router,
    prefix=settings.API_V1_PREFIX
)

app.include_router(
    workflow_router,
    prefix=settings.API_V1_PREFIX
)

app.include_router(
    ai_router,
    prefix=settings.API_V1_PREFIX
)

app.include_router(
    audit_router,
    prefix=settings.API_V1_PREFIX
)

app.include_router(
    application_router,
    prefix=settings.API_V1_PREFIX
)

@app.get("/")
def root():
    return {
        "message": "Welcome to TrackGov AI Backend",
        "version": settings.VERSION
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME
    }
