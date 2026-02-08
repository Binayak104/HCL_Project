import chromadb
from chromadb.config import Settings
import os

class ChromaService:
    def __init__(self):
        # Connect to the local ChromaDB running in Docker
        self.client = chromadb.HttpClient(host=os.getenv('CHROMA_HOST', 'localhost'), port=8000)
        self.collection = self.client.get_or_create_collection(name="hmrc_assessments")

    def add_document(self, doc_id: str, text: str, metadata: dict):
        self.collection.add(
            documents=[text],
            metadatas=[metadata],
            ids=[doc_id]
        )

    def query_similar(self, text: str, n_results: int = 3):
        results = self.client.query(
            query_texts=[text],
            n_results=n_results
        )
        return results

chroma_service = ChromaService()
