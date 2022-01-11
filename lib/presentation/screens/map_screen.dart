import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/business_logic/cubit/maps/maps_cubit.dart';
import 'package:maps/constants/my_colors.dart';
import 'package:maps/data/models/place.dart';
import 'package:maps/data/models/place_suggestion.dart';
import 'package:maps/helpers/location_helper.dart';
import 'package:maps/presentation/widgets/my_drawer.dart';
import 'package:maps/presentation/widgets/place_item.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static Position? position;
  Completer<GoogleMapController> _mapController = Completer();

  FloatingSearchBarController floatingSearchBarController =
      FloatingSearchBarController();
  List<PlaceSuggestion> places = [];
  MapType mapType = MapType.normal;
  MapType iSNormalMapType = MapType.normal;
  MapType isSatelliteMapType = MapType.satellite;

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    target: LatLng(position!.latitude, position!.longitude),
    bearing: 0.0,
    tilt: 0.0,
    zoom: 17,
  );

  // these variables for getLocationPlace----------------------->
  Set<Marker> markers = Set();
  late PlaceSuggestion placeSuggestion;
  late Place selectPlace;
  late Marker searchesPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchForPlaceCamera;

  void buildCameraNewPosition() {
    goToSearchForPlaceCamera = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(selectPlace.result.geometry.location.lat,
          selectPlace.result.geometry.location.lng),
      zoom: 13,
    );
  }

  @override
  void initState() {
    super.initState();
    getMyCurrentPosition();
  }

  Future<void> getMyCurrentPosition() async {
    await LocationHelper.getCurrentLocation();
    position = await Geolocator.getCurrentPosition().whenComplete(() {
      setState(() {});
    });
  }

  Widget buildMap(MapType mapType) {
    return GoogleMap(
      // mapType: MapType.normal,
      mapType: mapType,
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      initialCameraPosition: _myCurrentLocationCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
    );
  }

  Future<void> _goToMyCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_myCurrentLocationCameraPosition));
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      controller: floatingSearchBarController,
      elevation: 6,
      hintStyle: TextStyle(fontSize: 18),
      queryStyle: TextStyle(fontSize: 18),
      hint: 'Find Place..',
      border: BorderSide(
        style: BorderStyle.none,
      ),
      margins: EdgeInsets.fromLTRB(20, 50, 20, 0),
      // padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      iconColor: MyColors.blue,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        getPlacesSuggestions(query);
      },
      onFocusChanged: (_) {},
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: Icon(
              Icons.place,
              //  color: Colors.black.withOpacity(0.6),
              color: MyColors.blue,
            ),
            onPressed: () {},
          ),
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionBloc(),
              buildSelectedPlaceLocationBloc(),
            ],
          ),
        );
      },
    );
  }

  Widget buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectPlace = (state).place;
          goToMySearchedForLocation();
        }
      },
      child: Container(),
    );
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controllerNewCamera = await _mapController.future;
    controllerNewCamera.animateCamera(
        CameraUpdate.newCameraPosition(goToSearchForPlaceCamera));
    buildSearchedPlaceMarker();
  }

  void buildSearchedPlaceMarker() {
    searchesPlaceMarker = Marker(
      position: goToSearchForPlaceCamera.target,
      markerId: MarkerId('1'),
      onTap: ()  {
        buildCurrentLocationMarker();
      },
      infoWindow: InfoWindow(
        title: "${placeSuggestion.description}",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersUpdateUI(searchesPlaceMarker);
  }

  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
      position: LatLng(position!.latitude, position!.longitude),
      markerId: MarkerId('2'),
      onTap: () {
        buildCurrentLocationMarker();
      },
      infoWindow: InfoWindow(
        title: "Your Current Location ",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersUpdateUI(currentLocationMarker);
  }

  void addMarkerToMarkersUpdateUI(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }

  void getPlacesSuggestions(String query) {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestions(query, sessionToken);
  }

  Widget buildSuggestionBloc() {
    return BlocBuilder<MapsCubit, MapsState>(builder: (context, state) {
      if (state is PlaceLoaded) {
        places = (state).places;
        if (places.length != 0) {
          return buildPlacesList();
        } else
          return Container();
      }
      return Container();
    });
  }

  Widget buildPlacesList() {
    return ListView.builder(
      itemBuilder: (context, index) {

        return InkWell(
          onTap: () async {
            placeSuggestion = places[index];
            floatingSearchBarController.close();
            getSelectedPlaceLocation();
            // lesa feh haggaaa hena ------->>>>
          },
          child: PlaceItem(
            suggestion: places[index],
          ),
        );
      },
      itemCount: places.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
    );
  }

  void getSelectedPlaceLocation() {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }

  Widget buildButtomTypeMap(MapType mapType) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 8, 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade400,
          ),
          child: IconButton(
            onPressed: () {
              setState(() {});
              this.mapType = iSNormalMapType;
            },
            icon: Icon(
              Icons.add_circle_outline_outlined,
              size: 15,
              color: MyColors.blue,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 8, 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade400,
          ),
          child: IconButton(
            onPressed: () {
              setState(() {});
              this.mapType = isSatelliteMapType;
            },
            icon: Icon(
              Icons.add_circle,
              size: 15,
              color: MyColors.blue,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        drawer: MyDrawer(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            position != null
                ? buildMap(mapType)
                : Center(
                    child: CircularProgressIndicator(
                      color: MyColors.blue,
                    ),
                  ),
            buildFloatingSearchBar(),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildButtomTypeMap(mapType),
            //  Icon(Icons.add_circle_outline_outlined, size: 30),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 8, 30),
              child: FloatingActionButton(
                backgroundColor: MyColors.blue,
                onPressed: _goToMyCurrentLocation,
                child: Icon(Icons.place, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
