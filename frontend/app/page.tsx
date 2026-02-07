import AssessmentForm from "@/components/AssessmentForm";

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-4xl font-extrabold text-gray-900 sm:text-5xl sm:tracking-tight lg:text-6xl">
            HMRC Engagement Assessment
          </h1>
          <p className="mt-5 max-w-xl mx-auto text-xl text-gray-500">
            Automated IR35 risk analysis and classification tool.
          </p>
        </div>

        <AssessmentForm />
      </div>
    </main>
  );
}
