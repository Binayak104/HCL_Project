from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "service": "hmrc-assessment-api"}

def test_create_assessment():
    response = client.post("/assess", json={"engagement_details": "A" * 50})
    assert response.status_code == 200
    data = response.json()
    assert "risk_score" in data
    assert "explanation" in data

def test_assessment_validation():
    response = client.post("/assess", json={"engagement_details": "short"})
    assert response.status_code == 422
