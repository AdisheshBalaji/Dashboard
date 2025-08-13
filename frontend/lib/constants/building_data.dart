enum BuildingType {
  computerScienceAndElectrical(
    top: 290,
    left: 180,
    width: 15,
    height: 25,
  ),
  mechanicalEngineering(
    top: 290,
    left: 155,
    width: 25,
    height: 15,
  ),
  civilEngineering(
    top: 300,
    left: 145,
    width: 15,
    height: 25,
  ),
  chemicalEngineering(
    top: 320,
    left: 160,
    width: 20,
    height: 10,
  ),
  chemistryDepartment(
    top: 332,
    left: 160,
    width: 20,
    height: 10,
  ),
  bioMedAndTech(
    top: 332,
    left: 148,
    width: 10,
    height: 25,
  ),
  materialScience(
    top: 350,
    left: 160,
    width: 20,
    height: 8,
  ),
  researchCenterComplex(
    top: 315,
    left: 180,
    width: 17,
    height: 15,
  ),
  mathAndPhysics(
    top: 333,
    left: 180,
    width: 15,
    height: 25,
  ),
  krc(
    top: 367,
    left: 185,
    width: 10,
    height: 10,
  ),
  admin(
    top: 380,
    left: 187,
    width: 10,
    height: 15,
  ),
  lectureHallComplex(
    top: 358,
    left: 140,
    width: 40,
    height: 18,
  ),
  designDepartment(
    top: 382,
    left: 160,
    width: 20,
    height: 10,
  ),
  bvrScient(
    top: 400,
    left: 160,
    width: 10,
    height: 18,
  ),
  technologyIncubationPark(
    top: 315,
    left: 180,
    width: 15,
    height: 15,
  ),
  // Hostel Blocks
  bhabha(
    top: 243.5,
    left: 165,
    width: 11,
    height: 5,
  );

  final double top;
  final double left;
  final double width;
  final double height;

  const BuildingType({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
}

class BuildingInfo {
  final String name;
  final String description;
  final List<String> tags;
  final double latitude;
  final double longitude;
  final String? mapLink;

  const BuildingInfo({
    required this.name,
    required this.description,
    required this.tags,
    required this.latitude,
    required this.longitude,
    this.mapLink,
  });
}

const Map<BuildingType, BuildingInfo> buildingData = {
  BuildingType.computerScienceAndElectrical: BuildingInfo(
      name: 'Department of Computer Science & Engineering',
      description:
          'Houses the Computer Science & Engineering department with advanced computing labs, AI/ML research spaces, and collaborative project zones.',
      tags: ['Academic Building', 'Lab'],
      latitude: 17.5946,
      longitude: 78.1229,
      mapLink: 'https://maps.app.goo.gl/FemK67v79odSJ8Zv7'),
  BuildingType.mechanicalEngineering: BuildingInfo(
    name: 'Department of Mechanical & Aerospace Engineering',
    description:
        'Home to Mechanical & Aerospace Engineering, featuring workshops, design studios, thermal-fluid labs, and robotics research facilities.',
    tags: ['Academic Building', 'Engineering'],
    latitude: 17.5932,
    longitude: 78.1234,
  ),
  BuildingType.civilEngineering: BuildingInfo(
    name: 'Department of Civil Engineering',
    description:
        'Contains Civil Engineering classrooms, structural and geotechnical labs, and facilities supporting infrastructure research.',
    tags: ['Academic Building', 'Engineering'],
    latitude: 17.5934,
    longitude: 78.1231,
  ),
  BuildingType.chemicalEngineering: BuildingInfo(
    name: 'Department of Chemical Engineering',
    description:
        'Equipped with modern chemical process labs, pilot-scale facilities, and classrooms for Chemical Engineering research and teaching.',
    tags: ['Academic Building', 'Laboratory'],
    latitude: 17.5938,
    longitude: 78.1240,
  ),
  BuildingType.chemistryDepartment: BuildingInfo(
    name: 'Department of Chemistry',
    description:
        'Dedicated research and teaching labs, instrumentation suites, and lecture spaces for advanced chemistry education and research.',
    tags: ['Academic Building', 'Laboratory'],
    latitude: 17.5940,
    longitude: 78.1242,
  ),
  BuildingType.bioMedAndTech: BuildingInfo(
    name: 'Department of Biomedical Engineering',
    description:
        'Features bioinstrumentation labs, medical device prototyping spaces, and collaborative research environments in biomedical engineering.',
    tags: ['Academic Building', 'Laboratory', 'Research'],
    latitude: 17.5942,
    longitude: 78.1245,
  ),
  BuildingType.materialScience: BuildingInfo(
    name: 'Department of Materials Science & Metallurgical Engineering',
    description:
        'Focus on materials research with nanofabrication labs, metallurgy facilities, and equipment for materials characterization.',
    tags: ['Academic Building', 'Laboratory'],
    latitude: 17.5944,
    longitude: 78.1247,
  ),
  BuildingType.researchCenterComplex: BuildingInfo(
    name: 'Research Centre Complex',
    description:
        'Cluster of multi-disciplinary research centres supporting advanced sponsored, interdisciplinary, and collaborative projects.',
    tags: ['Research', 'Innovation'],
    latitude: 17.5947,
    longitude: 78.1228,
  ),
  BuildingType.mathAndPhysics: BuildingInfo(
    name: 'Departments of Mathematics & Physics',
    description:
        'Combined facility hosting Mathematics and Physics departments, with computational labs, theoretical research spaces, and physics experiment labs.',
    tags: ['Academic Building', 'Laboratory'],
    latitude: 17.5948,
    longitude: 78.1230,
  ),
  BuildingType.krc: BuildingInfo(
    name: 'Knowledge Resource Centre (Library)',
    description:
        'Central library offering extensive physical and digital collections, study zones, and research support services for the campus community.',
    tags: ['Library', 'Academic Resource'],
    latitude: 17.5951,
    longitude: 78.1232,
  ),
  BuildingType.admin: BuildingInfo(
    name: 'Administrative Block',
    description:
        'Central administration housing offices of Director, Registrar, various Deans, and academic & administrative services.',
    tags: ['Administration'],
    latitude: 17.5953,
    longitude: 78.1233,
  ),
  BuildingType.lectureHallComplex: BuildingInfo(
    name: 'Lecture Hall Complex',
    description:
        'Large architectural structure with multiple lecture halls, designed for accessibility, acoustics, and abundant natural lighting.',
    tags: ['Academic Building', 'Lecture Halls'],
    latitude: 17.5929,
    longitude: 78.1221,
  ),
  BuildingType.designDepartment: BuildingInfo(
    name: 'Department of Design',
    description:
        'Design studios and labs for industrial, UX/UI, and product design with prototyping equipment and collaborative workspace infrastructure :contentReference[oaicite:1]{index=1}.',
    tags: ['Academic Building', 'Design', 'Innovation'],
    latitude: 17.5950,
    longitude: 78.1248,
  ),
  BuildingType.bvrScient: BuildingInfo(
    name: 'B V Raju Science Centre',
    description:
        'Interdisciplinary science facility supporting foundational research in Physics, Chemistry, and Mathematics with modern laboratories.',
    tags: ['Research', 'Science'],
    latitude: 17.5952,
    longitude: 78.1249,
  ),
  BuildingType.technologyIncubationPark: BuildingInfo(
    name: 'Technology Incubation Park',
    description:
        'Innovation ecosystem encouraging startups, technology translation, and industry-academia partnerships within the campus.',
    tags: ['Innovation', 'Research'],
    latitude: 17.5941,
    longitude: 78.1210,
  ),
  BuildingType.bhabha: BuildingInfo(
    name: 'Bhabha Hostel Block',
    description:
        'Residential hostel providing accommodation, shared amenities, and communal living spaces for students on campus.',
    tags: ['Hostel', 'Residential'],
    latitude: 17.5955,
    longitude: 78.1250,
  ),
};
