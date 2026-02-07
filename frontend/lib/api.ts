const API_BASE_URL = 'http://localhost:8000';

export interface AssessmentResponse {
    id: string;
    risk_score: string;
    triage_determination: string;
    explanation: string;
    created_at: string;
}

export async function submitAssessment(engagementDetails: string): Promise<AssessmentResponse> {
    const response = await fetch(`${API_BASE_URL}/assess`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ engagement_details: engagementDetails }),
    });

    if (!response.ok) {
        throw new Error('Failed to submit assessment');
    }

    return response.json();
}

export async function getAssessments(): Promise<AssessmentResponse[]> {
    const response = await fetch(`${API_BASE_URL}/assessments`);
    if (!response.ok) {
        throw new Error('Failed to fetch assessments');
    }
    return response.json();
}

export async function getAssessment(id: string): Promise<AssessmentResponse> {
    const response = await fetch(`${API_BASE_URL}/assessments/${id}`);
    if (!response.ok) {
        throw new Error('Failed to fetch assessment');
    }
    return response.json();
}
