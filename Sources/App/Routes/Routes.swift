import Vapor
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        get("patients") { request in
            //Decode request
            guard let providerID = request.headers["providerID"] else {
                return Response(status: .badRequest)
            }
            //Query database for all patients supplied by GET header
            let patients = try Patient.makeQuery().filter("providerID",.equals, providerID).all()
            
            //Compose JSON to return for GET request.
            var returnJSON = JSON()
            for patient in patients {
                var patientJSON = JSON()
                try patientJSON.set("patientID", patient.patientID)
                try patientJSON.set("providerID", patient.providerID)
                try patientJSON.set("content", patient.content)
                returnJSON[patient.patientID] = patientJSON
            }
            return returnJSON
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
            guard let patientID = json["patientID"] as? String else {
                return Response(status: .badRequest)
            }
            guard let providerID = json["providerID"] else {
                return Response(status: .badRequest)
            }
            guard let content = json["content"] as? ByteData else {
                return Response(status: .badRequest)
            }
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
