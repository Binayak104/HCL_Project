# Trigger Backend Deployment
from fastapi import FastAPI

from mangum import Mangum
from fastapi.middleware.cors import CORSMiddleware
from backend.api import assessment, override

app = FastAPI(
    title="HMRC Engagement Assessment API",
    description="API for risk scoring, triage, and human overrides.",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(assessment.router, tags=["Assessment"])
app.include_router(override.router, tags=["Override"])

@app.get("/")
def health_check():
    return {"status": "healthy", "service": "hmrc-assessment-api"}

# Handler for AWS Lambda
handler = Mangum(app)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
