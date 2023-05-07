// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
contract Patient {
    struct patientData{
        string firstName;
        string lastName;
    }
    struct prescription{
        address doctor;
        string diagnosis;
        string medications;
        string date;
    }
   mapping(address=>patientData) patients;
   mapping(address=>address) permissions;
   mapping(address=>prescription[]) prescriptions;
   mapping(address=>bool) patientExist;
   function addPatient(string memory firstName, string memory lastName) public {
    patientData memory patient;
    patient.firstName=firstName;
    patient.lastName=lastName;
    patients[msg.sender]=patient;
    patientExist[msg.sender]=true;
   }
   function permission(address doctor) public {
        permissions[msg.sender]=doctor;
   }
   function deletePermission() public {
        delete permissions[msg.sender];
   }
   function checkPermission(address patient,address doctor) public view returns(bool){
    return(permissions[patient]==doctor);
   }
   function setPrescription(address patient,string memory diagnosis,string memory medications,string memory date, address doctor) public {
        require(checkPermission(patient,doctor),"Permission denied");
        prescription memory pres;
        pres.date=date;
        pres.diagnosis=diagnosis;
        pres.medications=medications;
        pres.doctor=doctor;
        prescriptions[patient].push(pres);
   }
    function exist() public view returns (bool){
        return (patientExist[msg.sender]);
    }
}
