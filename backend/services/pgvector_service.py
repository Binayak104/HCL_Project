import os
import psycopg2
from pgvector.psycopg2 import register_vector
from typing import List, Dict, Any

class PgVectorService:
    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = os.getenv('DB_PORT', '5432')
        self.dbname = os.getenv('DB_NAME', 'vecdb')
        self.user = os.getenv('DB_USER', 'dbadmin')
        self.password = os.getenv('DB_PASS', 'password123')
        self.conn = None
        self._init_db()

    def _get_connection(self):
        if self.conn is None or self.conn.closed:
            self.conn = psycopg2.connect(
                host=self.host,
                port=self.port,
                dbname=self.dbname,
                user=self.user,
                password=self.password
            )
            # Register pgvector with psycopg2
            with self.conn.cursor() as cur:
                cur.execute('CREATE EXTENSION IF NOT EXISTS vector')
                self.conn.commit()
            register_vector(self.conn)
        return self.conn

    def _init_db(self):
        try:
            conn = self._get_connection()
            with conn.cursor() as cur:
                cur.execute("""
                    CREATE TABLE IF NOT EXISTS assessments (
                        id UUID PRIMARY KEY,
                        content TEXT,
                        embedding VECTOR(1536), -- Assuming Bedrock embeddings
                        metadata JSONB,
                        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                    )
                """)
                conn.commit()
        except Exception as e:
            print(f"Error initializing database: {e}")

    def add_document(self, doc_id: str, text: str, embedding: List[float], metadata: Dict[str, Any]):
        try:
            conn = self._get_connection()
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO assessments (id, content, embedding, metadata) VALUES (%s, %s, %s, %s)",
                    (doc_id, text, embedding, psycopg2.extras.Json(metadata))
                )
                conn.commit()
        except Exception as e:
            print(f"Error adding document: {e}")
            raise e

    def query_similar(self, embedding: List[float], n_results: int = 3):
        try:
            conn = self._get_connection()
            with conn.cursor() as cur:
                # Use <-> for L2 distance, <=> for cosine distance, <#> for inner product
                cur.execute(
                    "SELECT id, content, metadata FROM assessments ORDER BY embedding <=> %s LIMIT %s",
                    (embedding, n_results)
                )
                return cur.fetchall()
        except Exception as e:
            print(f"Error querying similar: {e}")
            return []

pgvector_service = PgVectorService()
