"use client";

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { Card } from '@/components/ui/Card';
import { getAssessments, AssessmentResponse } from '@/lib/api';

export default function Dashboard() {
    const [assessments, setAssessments] = useState<AssessmentResponse[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        getAssessments()
            .then(setAssessments)
            .catch(console.error)
            .finally(() => setLoading(false));
    }, []);

    return (
        <div className="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-7xl mx-auto">
                <h1 className="text-3xl font-bold text-gray-900 mb-8">Assessment Dashboard</h1>

                {loading ? (
                    <p>Loading...</p>
                ) : (
                    <div className="space-y-4">
                        {assessments.map((a) => (
                            <Link key={a.id} href={`/assessments/${a.id}`}>
                                <Card className="flex justify-between items-center bg-white shadow-sm p-4 rounded-lg hover:shadow-md transition-shadow cursor-pointer">
                                    <div>
                                        <div className="text-sm text-gray-400">{new Date(a.created_at).toLocaleString()}</div>
                                        <div className="font-semibold text-gray-900">{a.triage_determination}</div>
                                        <div className="text-sm text-gray-500 truncate max-w-md">{a.explanation}</div>
                                    </div>
                                    <div className={`px-3 py-1 rounded-full text-sm font-bold ${a.risk_score === 'High' ? 'bg-red-100 text-red-800' :
                                        a.risk_score === 'Medium' ? 'bg-yellow-100 text-yellow-800' :
                                            'bg-green-100 text-green-800'
                                        }`}>
                                        {a.risk_score} Risk
                                    </div>
                                </Card>
                            </Link>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
