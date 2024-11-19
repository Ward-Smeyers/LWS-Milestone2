from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from os import environ
from time import sleep
from pymongo import MongoClient


app = FastAPI()

origins = [
    environ["FRONTEND_URL"]
]


app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup_db_client():
    print(f"Cross-Origin Resource Sharing enabled for {origins}!")
    print("Connecting to the MongoDB database!")
    app.mongodb_client = MongoClient(f'mongodb://{environ["MONGODB_USERNAME"]}:{environ["MONGODB_PASSWORD"]}@{environ["MONGODB_HOST"]}', tls=False)
    app.database = app.mongodb_client[environ["MONGODB_HOST"]]
    app.collection = app.database["name"]
    connected = False
    retry_count = 0
    max_retries = environ["MAX_RETRIES"]
    while connected == False:
        try:
            app.mongodb_client.admin.command("ping")
            connected = True
            print(f"Connected to the MongoDB database! after {retry_count} retries")
        except Exception as e:
            print(f"Unable to connect to the database on try {retry_count}!")
            print(f"error: {e}")
            if retry_count >= max_retries:
                print("Max retries reached, exiting!")
                exit(1)
            sleep(2**retry_count)
        
    if app.collection.find({ "_id": 1}).to_list() == []:
        print("Database is empty!\nInserting data!")
        app.collection.insert_one({ "_id": 1, "name": "Ward Smeyers" })


@app.on_event("shutdown")
def shutdown_db_client():
    print("Closing connection to MongoDB!")
    app.mongodb_client.close()
    print("Connection to MongoDB closed!")


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/user")
def read_item():
    resp = app.collection.find({ "_id": 1}).to_list()
    return {"name": resp[0].get("name")}


@app.post("/user/update")
def read_item(name = "Ward Smeyers"):
    app.collection.update_one({ "_id": 1 }, { "$set": { "name": name } })
    
    resp = app.collection.find({ "_id": 1}).to_list()
    return {"name": resp[0].get("name")}
