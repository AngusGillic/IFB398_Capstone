import '../models/garden_catalogue.dart';
import '../models/pet_state.dart';
import '../models/pet_trip.dart';

abstract class PetRepository {
  bool get local => false;

  Future<PetState> fetch(String owner);
  Future<GardenCatalogue> fetchCatalogue(String owner);
  Future<PetState> save(
    String owner,
    String operation,
    Map<String, dynamic> body,
  );
  Future<List<PetTrip>> trips(String owner) async => [];
}
