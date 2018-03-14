

createTables = function(db) {

    createVersionTable(db);
    createOrganismTable(db);
    createMimatTable(db);
    createMiTable(db);
    createMi2MimatTable(db);

    # dbSendQuery(db, "DROP TABLE version;")

}

createMiTable = function(db) {

    dbExecute(db,
        "CREATE TABLE mi (
	    accession TEXT(2000000000),
        name TEXT(2000000000),
        \"change\" TEXT(2000000000),
        \"sequence\" TEXT(2000000000),
        version NUMERIC (2, 1),
        organism TEXT(2000000000),
        CONSTRAINT MI_PK PRIMARY KEY (name,version),
        CONSTRAINT FK_mi_organism FOREIGN KEY (organism) REFERENCES organism(organism),
        CONSTRAINT FK_mi_version FOREIGN KEY (version) REFERENCES version(\"number\"));");

        # CREATE UNIQUE INDEX sqlite_autoindex_mi_1 ON miRBaseVersions.mi (name,version);

}

createMimatTable = function(db) {
    dbExecute(db,
        "CREATE TABLE mimat (
	    accession TEXT(2000000000),
        name TEXT(2000000000),
        \"sequence\" TEXT(2000000000),
        version REAL,
        organism TEXT(2000000000),
        CONSTRAINT MIMAT_PK PRIMARY KEY (name,version),
        CONSTRAINT mimat_organism_FK FOREIGN KEY (organism) REFERENCES organism(organism),
        CONSTRAINT mimat_version_FK FOREIGN KEY (version) REFERENCES version(\"number\"));");

        # CREATE UNIQUE INDEX sqlite_autoindex_mimat_1 ON mimat (name,version);

}

createVersionTable = function(db) {
    dbExecute(db,
        "CREATE TABLE version (\"number\" REAL, information INTEGER,
         CONSTRAINT version_PK PRIMARY KEY (\"number\"));");
}

createOrganismTable = function(db) {

    dbExecute(db,
    "CREATE TABLE organism (
    	organism TEXT(2000000000),
    	division TEXT(2000000000),
    	name TEXT(2000000000),
    	tree TEXT(2000000000),
    	NCBItaxid INTEGER,
    	CONSTRAINT ORGANISM_PK PRIMARY KEY (organism)
    );");

    # dbExecute(db,
    #     "CREATE UNIQUE INDEX sqlite_autoindex_organism_1 ON organism (organism);
    #      CREATE UNIQUE INDEX sqlite_autoindex_organism_2 ON organism (NCBItaxid);");

}

createMi2MimatTable = function(db) {

    dbExecute(db,
        "CREATE TABLE mi2mimat (
    	\"accession_mi\" TEXT(2000000000),
    	\"accession_mimat\" TEXT(2000000000),
        \"version\" REAL,
        CONSTRAINT mi2mimat_mi_FK FOREIGN KEY (accession_mi,version) REFERENCES mi(accesion,version),
        CONSTRAINT mi2mimat_mimat_FK FOREIGN KEY (accession_mimat,version) REFERENCES mimat(accesion,version));");
}



