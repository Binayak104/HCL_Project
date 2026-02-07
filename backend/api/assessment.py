from fastapi import APIRouter, HTTPException
from backend.models.schemas import AssessmentRequest, AssessmentResponse
from backend.services.bedrock_service import BedrockService
from backend.services.chroma_service import ChromaService
from uuid import uuid4
from datetime import datetime

router = APIRouter()
bedrock_service = BedrockService()
chroma_service = ChromaService()

@router.post("/assess", response_model=AssessmentResponse)
async def create_assessment(request: AssessmentRequest):
    # 1. Generate assessment using Bedrock
    assessment_result = bedrock_service.classify_risk(request.engagement_details)
    
    assessment_id = str(uuid4())
    
    # 2. Store in ChromaDB for RAG/History
    try:
        chroma_service.add_document(
            doc_id=assessment_id,
            text=request.engagement_details,
            metadata={
                "risk_score": assessment_result.get("risk_score", "Unknown"),
                "triage": assessment_result.get("triage_determination", "Unknown"),
                "timestamp": str(datetime.utcnow())
            }
        )
    except Exception as e:
        print(f"Warning: Failed to store in ChromaDB: {e}")

    return AssessmentResponse(
        id=assessment_id,
        risk_score=assessment_result.get("risk_score", "Medium"),
        triage_determination=assessment_result.get("triage_determination", "Manual Review"),
        explanation=assessment_result.get("explanation", "AI analysis unavailable."),
        created_at=datetime.utcnow()
    )

@router.get("/assessments")
async def get_assessments():
    # Mock return list
    return [
        {
            "id": "mock-id-1",
            "risk_score": "Low",
            "triage_determination": "Auto-approve",
            "explanation": "Mock explanation 1",
            "created_at": datetime.utcnow()
        }
    ]

@router.get("/assessments/{id}", response_model=AssessmentResponse)
async def get_assessment(id: str):
    return AssessmentResponse(
        id=id,
        risk_score="Medium",
        triage_determination="Junior Review",
        explanation="This is a mock detailed explanation for the assessment. The engagement text contained risky clauses.",
        created_at=datetime.utcnow()
    )
