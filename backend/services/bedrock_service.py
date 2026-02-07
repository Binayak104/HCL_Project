import boto3
import json
import os

class BedrockService:
    def __init__(self):
        self.client = boto3.client('bedrock-runtime', region_name='us-east-1')
        self.model_id = "amazon.nova-micro-v1:0" # Adjust model ID as needed for Nova

    def classify_risk(self, text: str):
        prompt = f"""
        You are an expert in IR35 legislation and HMRC employment status compliance.
        Analyze the following engagement details and determine the IR35 risk level (Low, Medium, High).
        Provide a triage determination (Auto-approve, Junior Review, Senior Review) and an explanation.
        
        Engagement Details:
        {text}
        
        Output JSON format:
        {{
            "risk_score": "Low|Medium|High",
            "triage_determination": "Auto-approve|Junior Review|Senior Review",
            "explanation": "concise explanation"
        }}
        """

        body = json.dumps({
            "inferenceConfig": {
                "max_new_tokens": 1000
            },
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"text": prompt}
                    ]
                }
            ]
        })

        try:
            response = self.client.invoke_model(
                modelId=self.model_id,
                body=body
            )
            response_body = json.loads(response['body'].read())
            # Nova/Claude 3 format usually has content[0].text
            # Adjust parsing based on specific model response structure
            output_text = response_body['output']['message']['content'][0]['text']
            
            # Extract JSON from output if it wraps it in markdown code blocks
            if "```json" in output_text:
                output_text = output_text.split("```json")[1].split("```")[0].strip()
            elif "```" in output_text:
                 output_text = output_text.split("```")[1].split("```")[0].strip()
                 
            return json.loads(output_text)

        except Exception as e:
            print(f"Error invoking Bedrock: {e}")
            # Fallback for now/testing
            return {
                "risk_score": "Medium",
                "triage_determination": "Junior Review",
                "explanation": f"Error calling AI model: {str(e)}. Defaulting to manual review."
            }

bedrock_service = BedrockService()
