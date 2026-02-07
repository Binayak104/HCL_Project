"use client";

import React, { useState } from 'react';
import { Button } from './ui/Button';
import { Card } from './ui/Card';
import { submitAssessment, AssessmentResponse } from '@/lib/api';

export default function AssessmentForm() {
    const [details, setDetails] = useState('');
    const [result, setResult] = useState<AssessmentResponse | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        setResult(null);

        try {
            const data = await submitAssessment(details);
            setResult(data);
        } catch (err) {
            setError('Failed to submit assessment. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="max-w-2xl mx-auto space-y-8">
            <Card>
                <h2 className="text-2xl font-bold mb-4 text-gray-800">New Engagement Assessment</h2>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label htmlFor="details" className="block text-sm font-medium text-gray-700 mb-1">
                            Engagement Details (Job Description / Contract)
                        </label>
                        <textarea
                            id="details"
                            rows={6}
                            className="w-full text-black px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                            placeholder="Paste the contract text or job description here (min 50 chars)..."
                            value={details}
                            onChange={(e) => setDetails(e.target.value)}
                            required
                            minLength={50}
                        />
                    </div>
                    <Button type="submit" isLoading={loading} className="w-full">
                        Analyze Risk
                    </Button>
                </form>
                {error && (
                    <div className="mt-4 p-3 bg-red-50 text-red-700 rounded-md">
                        {error}
                    </div>
                )}
            </Card>

            {result && (
                <Card className="animate-fade-in">
                    <h3 className="text-xl font-semibold mb-4 text-gray-800">Assessment Result</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div className="p-4 bg-gray-50 rounded-lg">
                            <span className="block text-sm text-gray-500">Risk Score</span>
                            <span className={`text-lg font-bold ${result.risk_score === 'High' ? 'text-red-600' :
                                    result.risk_score === 'Medium' ? 'text-yellow-600' : 'text-green-600'
                                }`}>
                                {result.risk_score}
                            </span>
                        </div>
                        <div className="p-4 bg-gray-50 rounded-lg">
                            <span className="block text-sm text-gray-500">Triage Determination</span>
                            <span className="text-lg font-bold text-gray-900">{result.triage_determination}</span>
                        </div>
                    </div>
                    <div className="bg-blue-50 p-4 rounded-lg">
                        <h4 className="font-medium text-blue-900 mb-2">Explanation</h4>
                        <p className="text-blue-800 text-sm">{result.explanation}</p>
                    </div>
                </Card>
            )}
        </div>
    );
}
