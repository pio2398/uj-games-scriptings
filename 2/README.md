**To run**

- Install dependencies using poetry.
- Train model `rasa train`
- Replace API key in Discord proxy in discord_integration `main.py`
- Start main rasa process `rasa run`
- Start action process `rasa run --enable-api actions`
- Start Discord proxy `python main.py`