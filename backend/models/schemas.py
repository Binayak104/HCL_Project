from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID, uuid4

class AssessmentRequest(BaseModel):
    engagement_details: str = Field(..., min_length=50, description="The full text of the job description or contract.")

class AssessmentResponse(BaseModel):
    id: str
    risk_score: str = Field(..., description="Low, Medium, or High")
    triage_determination: str = Field(..., description="Auto-approve, Junior Review, or Senior Review")
    explanation: str
    created_at: datetime

class OverrideRequest(BaseModel):
    assessment_id: str
    original_text: str
    override_risk_score: str
    override_triage: str
    reason: str

class OverrideResponse(BaseModel):
    id: str
    assessment_id: str
    status: str = "logged"
    created_at: datetime
