# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

import json
from pprint import pprint
from typing import Any, Dict, List, Text

import yaml
from rasa_sdk import Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.interfaces import Action
from rasa_sdk.events import SlotSet
from storage.tournaments_storage import tournaments_storage_instance, Tournament


class ActionRegisterPlayer(Action):
    def name(self) -> Text:
        return "action_register_player"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        tournaments: list[Tournament] = tournaments_storage_instance.get_all()

        cur_values = tracker.current_slot_values()
        match_name = cur_values["match_name"]
        player = cur_values["player_name"]

        tournaments = [
            t for t in tournaments if t["name"].lower() == match_name.lower()
        ]
        if not tournaments:
            msg = f"Can't find {match_name} tournament. Try again"
        elif len(tournaments) != 1:
            msg = f"Not expected number of event found."
        else:
            tournament = tournaments[0]
            tournaments_storage_instance.add_player(tournament.id, player=player)
            msg = f"Successfully added player '{player}' to tournament '{tournament.name}'."

        dispatcher.utter_message(text=msg)
        return [SlotSet("player_name", None), SlotSet("match_name", None)]
