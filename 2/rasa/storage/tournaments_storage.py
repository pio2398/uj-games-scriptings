from dataclasses import dataclass
from datetime import datetime
import typing


@dataclass
class Tournament:
    time: datetime
    players: list[str]
    name: str
    id: typing.Optional[int] = None


class TournamentsStorage:
    tournament_list: typing.Mapping[int, Tournament]

    def __init__(self) -> None:
        self.tournament_list = dict()

    def get_all(self) -> list[Tournament]:
        return self.tournament_list.values()

    def get_by_id(self, id: int) -> Tournament:
        return filter(lambda x: x.id == id, self.tournament_list)[0]

    def get_by_name(self, name: str) -> Tournament:
        return filter(lambda x: x.name == name, self.tournament_list)[0]

    def add(self, tournament: Tournament) -> Tournament:
        id = len(self.tournament_list) + 1
        tournament.id = id
        self.tournament_list[tournament.id] = tournament
        return tournament

    def add_player(self, tournament_id: int, player: str):
        self.get_by_id(tournament_id).players.append(player)


tournaments_storage_instance = TournamentsStorage()
tournaments_storage_instance.add(
    Tournament(name="Tournament a", time=datetime.now(), players=["a", "b"])
)
