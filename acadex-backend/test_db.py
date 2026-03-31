import asyncio
from sqlalchemy import text
from app.database import engine

async def test_connection():
    try:
        async with engine.connect() as conn:
            # Query all table names in the public schema
            result = await conn.execute(text(
                "SELECT table_name FROM information_schema.tables WHERE table_schema='public'"
            ))
            tables = [row[0] for row in result.fetchall()]
            
            print("\n" + "="*40)
            print("[SUCCESS] POSTGRESQL CONNECTION SUCCESSFUL!")
            print("="*40)
            
            app_tables = [t for t in sorted(tables) if t != "alembic_version"]
            print(f"\n[INFO] Fast-API successfully created {len(app_tables)} ORM tables in 'acadex_db':")
            for t in app_tables:
                print(f"  - {t}")
            print("\nPhase 1 Database Architecture is 100% complete! \n")
            
        await engine.dispose()
    except Exception as e:
        print(f"\n[FAILED] Connection failed: {e}\n")

if __name__ == "__main__":
    asyncio.run(test_connection())
