"use client";

import React, { useEffect, useState } from 'react';
import { Card } from '@/components/ui/Card';
import { getAssessment, AssessmentResponse } from '@/lib/api';
import { Button } from '@/components/ui/Button';
import { useRouter } from 'next/navigation';

export default function AssessmentDetails({ params }: { params: { id: string } }) {
    const [assessment, setAssessment] = useState<AssessmentResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const router = useRouter();

    // Unwrap params using React.use() if necessary in Next.js 15, but for now assuming standard prop access
    // or simple useEffect dependency. 
    // Note: In strict mode or newer Next.js versions, params might be a Promise.
    // We can treat it as such or just use the id if it's available.
    const id = params.id;

    useEffect(() => {
        if (!id) return;
        getAssessment(id)
            .then(setAssessment)
            .catch((err) => setError('Failed to load assessment'))
            .finally(() => setLoading(false));
    }, [id]);

    if (loading) return <div className="p-8 text-center">Loading...</div>;
    if (error || !assessment) return <div className="p-8 text-center text-red-600">{error || 'Assessment not found'}</div>;

    return (
        <div className="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto">
                <Button onClick={() => router.back()} variant="secondary" className="mb-6">
                    &larr; Back
                </Button>

                <Card className="mb-8">
                    <div className="border-b pb-4 mb-4 flex justify-between items-center">
                        <div>
                            <h1 className="text-2xl font-bold text-gray-900">Assessment Details</h1>
                            <p className="text-gray-500 text-sm">ID: {assessment.id}</p>
                        </div>
                        <span className={`px-4 py-2 rounded-full text-sm font-bold ${assessment.risk_score === 'High' ? 'bg-red-100 text-red-800' :
                                assessment.risk_score === 'Medium' ? 'bg-yellow-100 text-yellow-800' :
                                    'bg-green-100 text-green-800'
                            }`}>
                            {assessment.risk_score} Risk
                        </span>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <div>
                            <h3 className="text-sm font-medium text-gray-500 uppercase tracking-wider">Triage Determination</h3>
                            <p className="mt-1 text-lg font-semibold text-gray-900">{assessment.triage_determination}</p>
                        </div>
                        <div>
                            <h3 className="text-sm font-medium text-gray-500 uppercase tracking-wider">Created At</h3>
                            <p className="mt-1 text-lg text-gray-900">{new Date(assessment.created_at).toLocaleString()}</p>
                        </div>
                    </div>

                    <div className="bg-blue-50 p-6 rounded-lg mb-6">
                        <h3 className="text-lg font-medium text-blue-900 mb-2">Explanation</h3>
                        <p className="text-blue-800 whitespace-pre-wrap">{assessment.explanation}</p>
                    </div>
                </Card>
            </div>
        </div>
    );
}
