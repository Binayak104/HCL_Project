from fastapi import APIRouter, HTTPException
from backend.models.schemas import OverrideRequest, OverrideResponse
from uuid import uuid4
from datetime import datetime

router = APIRouter()

@router.post("/override", response_model=OverrideResponse)
async def create_override(request: OverrideRequest):
    # Log logic here
    print(f"Override received for {request.assessment_id}: {request.reason}")
    
    return OverrideResponse(
        id=str(uuid4()),
        assessment_id=request.assessment_id,
        status="success",
        created_at=datetime.utcnow()
    )

@router.get("/overrides")
async def get_overrides():
    return []
