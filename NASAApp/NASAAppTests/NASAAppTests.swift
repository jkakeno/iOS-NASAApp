//
//  NASAAppTests.swift
//  NASAAppTests
//
//  Created by Jun Kakeno on 2/16/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import XCTest
@testable import NASAApp

class NASAAppTests: XCTestCase {
    
    let client = ApiClient()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownloadAPOD() {
        
        let expectation = XCTestExpectation(description: "APOD was downloaded successfully")
        
        client.getAPOD(date: Date()) {apod, error in
            XCTAssert(apod != nil, "apod was unexpectedly nil")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDownloadMarsRover() {
        
        let expectation = XCTestExpectation(description: "Mars Photos were downloaded successfully")
        
        client.getMarsPhotos(rover: .curiosity, camera: "navcam", sol:"100" ){[unowned self] marsPhotos, error in
            XCTAssert(marsPhotos != nil, "Photos were unexpectedly nil")
            if let photos = marsPhotos {
                XCTAssert(!photos.isEmpty, "photos were unexpectedly empty")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEarthImagery() {
        
        let expectation = XCTestExpectation(description: "Earth Image was downloaded successfully")
        
        
        client.getEarthImage(lat: 25.7741564, long: -80.1936064, date: "2017-03-31"){[unowned self] earthImage, error in
            XCTAssert(earthImage != nil, "Earth Image was unexpectedly nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAPODParse() {
        let json = """
        {
            "date": "2019-03-17",
            "explanation": "What's happening at the center of spiral galaxy M106? A swirling disk of stars and gas, M106's appearance is dominated by blue spiral arms and red  dust lanes near the nucleus, as shown in the featured image.  The core of M106 glows brightly in radio waves and X-rays where twin jets have been found running the length of the galaxy.  An unusual central glow makes M106 one of the closest examples of the Seyfert class of galaxies, where vast amounts of glowing gas are thought to be falling into a central massive black hole.  M106, also designated NGC 4258, is a relatively close 23.5 million light years away, spans 60 thousand light years across, and can be seen with a small telescope towards the constellation of the Hunting Dogs (Canes Venatici).    Astrophysicists: Browse 1,900+ codes in the Astrophysics Source Code Library",
            "hdurl": "https://apod.nasa.gov/apod/image/1903/m106_colombari_3568.jpg",
            "media_type": "image",
            "service_version": "v1",
            "title": "M106: A Spiral Galaxy with a Strange Center",
            "url": "https://apod.nasa.gov/apod/image/1903/m106_colombari_960.jpg"
        }
        """.data(using: .utf8)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(formatter)
        let apod = try? decoder.decode(APOD.self, from: json)
        XCTAssert(apod != nil, "APOD was unexpectedly nil")
    }
    
    
    func testEarthImageParse() {
        let json = """
        {
            "date": "2017-04-16T15:49:28",
            "id": "LC8_L1T_TOA/LC80150422017106LGN00",
            "resource": {
                "dataset": "LC8_L1T_TOA",
                "planet": "earth"
            },
            "service_version": "v1",
            "url": "https://earthengine.googleapis.com/api/thumb?thumbid=457aa8c81521b80d72e49db4f76c1076&token=c8a9a5509555b233d13beb4d3fab65f5"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let earthImage = try? decoder.decode(EarthPhoto.self, from: json)
        XCTAssert(earthImage != nil, "Parsing Failed")
    }
    
    func testMarsRoverParse() {
        let json = """
        {
        "photos": [
           {
                    "id": 2019,
                    "sol": 100,
                    "camera": {
                        "id": 26,
                        "name": "NAVCAM",
                        "rover_id": 5,
                        "full_name": "Navigation Camera"
                    },
                    "img_src": "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00100/opgs/edr/ncam/NLA_406359343EDR_M0050104NCAM00505M_.JPG",
                    "earth_date": "2012-11-16",
                    "rover": {
                        "id": 5,
                        "name": "Curiosity",
                        "landing_date": "2012-08-06",
                        "launch_date": "2011-11-26",
                        "status": "active",
                        "max_sol": 2349,
                        "max_date": "2019-03-16",
                        "total_photos": 348131,
                        "cameras": [
                            {
                                "name": "FHAZ",
                                "full_name": "Front Hazard Avoidance Camera"
                            },
                            {
                                "name": "NAVCAM",
                                "full_name": "Navigation Camera"
                            },
                            {
                                "name": "MAST",
                                "full_name": "Mast Camera"
                            },
                            {
                                "name": "CHEMCAM",
                                "full_name": "Chemistry and Camera Complex"
                            },
                            {
                                "name": "MAHLI",
                                "full_name": "Mars Hand Lens Imager"
                            },
                            {
                                "name": "MARDI",
                                "full_name": "Mars Descent Imager"
                            },
                            {
                                "name": "RHAZ",
                                "full_name": "Rear Hazard Avoidance Camera"
                            }
                        ]
                    }
                },
                {
                    "id": 2609,
                    "sol": 100,
                    "camera": {
                        "id": 26,
                        "name": "NAVCAM",
                        "rover_id": 5,
                        "full_name": "Navigation Camera"
                    },
                    "img_src": "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00100/opgs/edr/ncam/NRA_406373677EDR_D0050104TRAV00024M_.JPG",
                    "earth_date": "2012-11-16",
                    "rover": {
                        "id": 5,
                        "name": "Curiosity",
                        "landing_date": "2012-08-06",
                        "launch_date": "2011-11-26",
                        "status": "active",
                        "max_sol": 2349,
                        "max_date": "2019-03-16",
                        "total_photos": 348131,
                        "cameras": [
                            {
                                "name": "FHAZ",
                                "full_name": "Front Hazard Avoidance Camera"
                            },
                            {
                                "name": "NAVCAM",
                                "full_name": "Navigation Camera"
                            },
                            {
                                "name": "MAST",
                                "full_name": "Mast Camera"
                            },
                            {
                                "name": "CHEMCAM",
                                "full_name": "Chemistry and Camera Complex"
                            },
                            {
                                "name": "MAHLI",
                                "full_name": "Mars Hand Lens Imager"
                            },
                            {
                                "name": "MARDI",
                                "full_name": "Mars Descent Imager"
                            },
                            {
                                "name": "RHAZ",
                                "full_name": "Rear Hazard Avoidance Camera"
                            }
                        ]
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let marsImages = try? decoder.decode([String:[MarsPhoto]].self, from: json)
        
        XCTAssert(marsImages != nil, "Mars Images were unexpectedly nil")
    }
    
}
