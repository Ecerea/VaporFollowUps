import Vapor
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        get("patients") { request in
            //Fake user
//            let bytes: [UInt8] = [6,7,88,97,66,46,45]
//            let patient = Patient(patientID: "Testing", providerID: "Testing", content: bytes)
//            try patient.save()
            
            
            let patients = try Patient.all()
            var json = JSON()
            let firstPatient = patients.first
            guard let patientID = firstPatient?.patientID else {
                return Response(status: .badRequest)
            }
            guard let providerID = firstPatient?.providerID else {
                return Response(status: .badRequest)
            }
            try json.set(patientID, providerID)
            try json.set("content", firstPatient?.content)
            return json
        }
        
        post("patient") { request in
            //Decode request
            let data: Data = Data(bytes: request.body.bytes!)
            
            var json = [String : Any]()
            do {
                json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                
            } catch {
                return Response(status: .badRequest)
            }
            print(json)
            guard let patientID = json["patientID"] as? String else {
                return Response(status: .badRequest)
            }
//            guard let providerID = json["providerID"] else {
//                return Response(status: .badRequest)
//            }
            guard let content = json["results"] as? ByteData else {
                return Response(status: .badRequest)
            }
            print(content)
            //Create New Patient
            let patient = Patient(patientID: patientID, providerID: "Testing", content: content)
            try patient.save()
            
            let patients = try Patient.all()
            var testingJSON = JSON()
            let firstPatient = patients.first
            guard let patID = firstPatient?.patientID else {
                return Response(status: .badRequest)
            }
            guard let proID = firstPatient?.providerID else {
                return Response(status: .badRequest)
            }
            try testingJSON.set("patientID", patID)
            try testingJSON.set("providerID", proID)
            try testingJSON.set("content", firstPatient?.content)
            print("Testing JSON \(testingJSON)")
            return testingJSON
        }
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}
