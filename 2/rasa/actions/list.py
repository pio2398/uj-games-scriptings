# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

import json
from typing import Any, Dict, List, Text

import yaml
from rasa_sdk import Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.interfaces import Action
from storage.tournaments_storage import tournaments_storage_instance, Tournament


class ActionListMatches(Action):
    def name(self) -> Text:
        return "action_list_matches"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        tournaments: list[Tournament] = tournaments_storage_instance.get_all()
        if len(tournaments) == 0:
            dispatcher.utter_message(text="There is not active tournaments.")
            return []

        msg = ""
        for tournament in tournaments:
            msg += f"Name: {tournament.name}, time: {tournament.time}, players: {', '.join(tournament.players)}"
            msg += "\n"
        dispatcher.utter_message(text=msg)

        return []
