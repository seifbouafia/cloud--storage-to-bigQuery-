function transform(line) {
    let values = line.split(',');

    let obj = new Object();
    obj.adress = values[2];
    obj.dateAjout = values[6];
    obj.email = values[7];
    obj.idEmploye = values[9];
    obj.nomAgence = values[13];
    let jsonString = JSON.stringify(obj);

    return jsonString;
}