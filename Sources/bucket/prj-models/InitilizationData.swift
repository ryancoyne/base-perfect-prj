//
//  InitilizationData.swift
//  bucket
//
//  Created by Mike Silvers on 8/8/18.
//

import Foundation
import PostgresStORM
import PerfectLocalAuthentication

final class InitializeData {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let createdby  = "AUTO_CREATED_USER"
    static let modifiedby = "AUTO_MODIFIED_USER"
    static let deletedby  = "AUTO_DELETED_USER"
    
    static let sharedInstance = InitializeData()
    
    func addPOS() {
        let tbl = POS()

        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name,model) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Clover', 'C300'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Clover','Clover Station') ")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        
    }

    func addContactTypes() {
        
        let tbl = ContactType()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name,description) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','billing','This is the main billing contact for the account.'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','manager','This is a manager for the account.'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','admin','This is the main billing contact for the account.'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','billing','This is an administrative contact for the account.')")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }

    
    func addCashoutTypes() {
        
        let tbl = CashoutTypes()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name,description) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Open Loop Gift Card','This card allows users to purchase anything using the giftcard.'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Closed Loop Gift Card','This card allows users to purchase from specific retailers using the giftcard.'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Donate','This allows the user to donate to a specific cause.'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Bucket Coin','This is the cryptocurrency for the Bucket users.')")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }
    
    func addForms() {
        
        let tbl = Form()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name, title) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','BUX Coin', 'BUX'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','US Open Loop', 'Prepaid Card'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','US Closed Loop', 'Gift Card'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','US Donation', 'Donate') ")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }
    
    func addFormFieldType() {

        let tbl = FormFieldType()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Checkbox'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Text'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Number'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','E-Mail'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Phone'), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Currency')")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addFormField() {

        let tbl = FormField()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name, type_id, length, is_required, needs_confirmation) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Full Name', 2, 25, TRUE, FALSE), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Email Address', 4, 50, TRUE, TRUE), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER','Keep me updated with new offers!', 1, 1, FALSE, FALSE) ")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addFormFields() {

        let tbl = FormFields()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, form_id, field_id, display_order) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 1, 1, 1), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 1, 2, 2), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 1, 3, 3), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 2, 1, 1), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 2, 2, 2), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 2, 3, 3), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 3, 1, 1), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 3, 2, 2), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 3, 3, 3), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 4, 1, 1), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 4, 2, 2), ")
        checkuser.append(" ('\(created_time)','ADMIN_USER', 4, 3, 3) ")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addCountryCodes() {
        let tbl = Country()
        
        let create_time = Int(Date().timeIntervalSince1970)

        var insertstatement = "INSERT INTO \(tbl.table())"
        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
        insertstatement.append(" VALUES ")
        insertstatement.append("('Afghanistan','4','AF','AFG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Åland Islands','248','AX','ALA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Albania','8','AL','ALB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Algeria','12','DZ','DZA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('American Samoa','16','AS','ASM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Andorra','20','AD','AND',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Angola','24','AO','AGO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Anguilla','660','AI','AIA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Antarctica','10','AQ','ATA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Antigua and Barbuda','28','AG','ATG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Argentina','32','AR','ARG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Armenia','51','AM','ARM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Aruba','533','AW','ABW',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Australia','36','AU','AUS',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Austria','40','AT','AUT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Azerbaijan','31','AZ','AZE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bahamas','44','BS','BHS',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bahrain','48','BH','BHR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bangladesh','50','BD','BGD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Barbados','52','BB','BRB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Belarus','112','BY','BLR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Belgium','56','BE','BEL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Belize','84','BZ','BLZ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Benin','204','BJ','BEN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bermuda','60','BM','BMU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bhutan','64','BT','BTN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bolivia (Plurinational State of)','68','BO','BOL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bonaire, Sint Eustatius and Saba','535','BQ','BES',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bosnia and Herzegovina','70','BA','BIH',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Botswana','72','BW','BWA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bouvet Island','74','BV','BVT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Brazil','76','BR','BRA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('British Indian Ocean Territory','86','IO','IOT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Brunei Darussalam','96','BN','BRN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Bulgaria','100','BG','BGR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Burkina Faso','854','BF','BFA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Burundi','108','BI','BDI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cabo Verde','132','CV','CPV',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cambodia','116','KH','KHM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cameroon','120','CM','CMR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Canada','124','CA','CAN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cayman Islands','136','KY','CYM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Central African Republic','140','CF','CAF',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Chad','148','TD','TCD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Chile','152','CL','CHL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('China','156','CN','CHN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Christmas Island','162','CX','CXR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cocos (Keeling) Islands','166','CC','CCK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Colombia','170','CO','COL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Comoros','174','KM','COM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Congo','178','CG','COG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Congo (Democratic Republic of the)','180','CD','COD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cook Islands','184','CK','COK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Costa Rica','188','CR','CRI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Côte d Ivoire','384','CI','CIV',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Croatia','191','HR','HRV',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cuba','192','CU','CUB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Curaçao','531','CW','CUW',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Cyprus','196','CY','CYP',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Czechia','203','CZ','CZE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Denmark','208','DK','DNK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Djibouti','262','DJ','DJI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Dominica','212','DM','DMA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Dominican Republic','214','DO','DOM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Ecuador','218','EC','ECU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Egypt','818','EG','EGY',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('El Salvador','222','SV','SLV',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Equatorial Guinea','226','GQ','GNQ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Eritrea','232','ER','ERI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Estonia','233','EE','EST',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Eswatini','748','SZ','SWZ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Ethiopia','231','ET','ETH',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Falkland Islands (Malvinas)','238','FK','FLK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Faroe Islands','234','FO','FRO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Fiji','242','FJ','FJI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Finland','246','FI','FIN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('France','250','FR','FRA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('French Guiana','254','GF','GUF',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('French Polynesia','258','PF','PYF',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('French Southern Territories','260','TF','ATF',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Gabon','266','GA','GAB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Gambia','270','GM','GMB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Georgia','268','GE','GEO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Germany','276','DE','DEU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Ghana','288','GH','GHA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Gibraltar','292','GI','GIB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Greece','300','GR','GRC',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Greenland','304','GL','GRL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Grenada','308','GD','GRD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Guadeloupe','312','GP','GLP',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Guam','316','GU','GUM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Guatemala','320','GT','GTM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Guernsey','831','GG','GGY',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Guinea','324','GN','GIN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Guinea-Bissau','624','GW','GNB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Guyana','328','GY','GUY',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Haiti','332','HT','HTI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Heard Island and McDonald Islands','334','HM','HMD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Holy See','336','VA','VAT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Honduras','340','HN','HND',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Hong Kong','344','HK','HKG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Hungary','348','HU','HUN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Iceland','352','IS','ISL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('India','356','IN','IND',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Indonesia','360','ID','IDN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Iran (Islamic Republic of)','364','IR','IRN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Iraq','368','IQ','IRQ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Ireland','372','IE','IRL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Isle of Man','833','IM','IMN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Israel','376','IL','ISR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Italy','380','IT','ITA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Jamaica','388','JM','JAM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Japan','392','JP','JPN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Jersey','832','JE','JEY',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Jordan','400','JO','JOR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Kazakhstan','398','KZ','KAZ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Kenya','404','KE','KEN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Kiribati','296','KI','KIR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Korea (Democratic Peoples Republic of)','408','KP','PRK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Korea (Republic of)','410','KR','KOR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Kuwait','414','KW','KWT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Kyrgyzstan','417','KG','KGZ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Lao Peoples Democratic Republic','418','LA','LAO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Latvia','428','LV','LVA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Lebanon','422','LB','LBN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Lesotho','426','LS','LSO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Liberia','430','LR','LBR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Libya','434','LY','LBY',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Liechtenstein','438','LI','LIE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Lithuania','440','LT','LTU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Luxembourg','442','LU','LUX',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Macao','446','MO','MAC',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Macedonia (the former Yugoslav Republic of)','807','MK','MKD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Madagascar','450','MG','MDG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Malawi','454','MW','MWI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Malaysia','458','MY','MYS',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Maldives','462','MV','MDV',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Mali','466','ML','MLI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Malta','470','MT','MLT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Marshall Islands','584','MH','MHL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Martinique','474','MQ','MTQ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Mauritania','478','MR','MRT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Mauritius','480','MU','MUS',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Mayotte','175','YT','MYT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Mexico','484','MX','MEX',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Micronesia (Federated States of)','583','FM','FSM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Moldova (Republic of)','498','MD','MDA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Monaco','492','MC','MCO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Mongolia','496','MN','MNG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Montenegro','499','ME','MNE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Montserrat','500','MS','MSR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Morocco','504','MA','MAR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Mozambique','508','MZ','MOZ',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Myanmar','104','MM','MMR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Namibia','516','NA','NAM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Nauru','520','NR','NRU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Nepal','524','NP','NPL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Netherlands','528','NL','NLD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('New Caledonia','540','NC','NCL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('New Zealand','554','NZ','NZL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Nicaragua','558','NI','NIC',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Niger','562','NE','NER',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Nigeria','566','NG','NGA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Niue','570','NU','NIU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Norfolk Island','574','NF','NFK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Northern Mariana Islands','580','MP','MNP',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Norway','578','NO','NOR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Oman','512','OM','OMN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Pakistan','586','PK','PAK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Palau','585','PW','PLW',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Palestine, State of','275','PS','PSE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Panama','591','PA','PAN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Papua New Guinea','598','PG','PNG',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Paraguay','600','PY','PRY',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Peru','604','PE','PER',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Philippines','608','PH','PHL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Pitcairn','612','PN','PCN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Poland','616','PL','POL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Portugal','620','PT','PRT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Puerto Rico','630','PR','PRI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Qatar','634','QA','QAT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Réunion','638','RE','REU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Romania','642','RO','ROU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Russian Federation','643','RU','RUS',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Rwanda','646','RW','RWA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saint Barthélemy','652','BL','BLM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saint Helena, Ascension and Tristan da Cunha','654','SH','SHN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saint Kitts and Nevis','659','KN','KNA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saint Lucia','662','LC','LCA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saint Martin (French part)','663','MF','MAF',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saint Pierre and Miquelon','666','PM','SPM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saint Vincent and the Grenadines','670','VC','VCT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Samoa','882','WS','WSM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('San Marino','674','SM','SMR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Sao Tome and Principe','678','ST','STP',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Saudi Arabia','682','SA','SAU',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Senegal','686','SN','SEN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Serbia','688','RS','SRB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Seychelles','690','SC','SYC',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Sierra Leone','694','SL','SLE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Singapore','702','SG','SGP',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Sint Maarten (Dutch part)','534','SX','SXM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Slovakia','703','SK','SVK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Slovenia','705','SI','SVN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Solomon Islands','90','SB','SLB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Somalia','706','SO','SOM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('South Africa','710','ZA','ZAF',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('South Georgia and the South Sandwich Islands','239','GS','SGS',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('South Sudan','728','SS','SSD',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Spain','724','ES','ESP',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Sri Lanka','144','LK','LKA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Sudan','729','SD','SDN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Suriname','740','SR','SUR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Svalbard and Jan Mayen','744','SJ','SJM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Sweden','752','SE','SWE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Switzerland','756','CH','CHE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Syrian Arab Republic','760','SY','SYR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Taiwan, Province of China','158','TW','TWN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Tajikistan','762','TJ','TJK',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Tanzania, United Republic of','834','TZ','TZA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Thailand','764','TH','THA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Timor-Leste','626','TL','TLS',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Togo','768','TG','TGO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Tokelau','772','TK','TKL',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Tonga','776','TO','TON',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Trinidad and Tobago','780','TT','TTO',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Tunisia','788','TN','TUN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Turkey','792','TR','TUR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Turkmenistan','795','TM','TKM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Turks and Caicos Islands','796','TC','TCA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Tuvalu','798','TV','TUV',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Uganda','800','UG','UGA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Ukraine','804','UA','UKR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('United Arab Emirates','784','AE','ARE',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('United Kingdom of Great Britain and Northern Ireland','826','GB','GBR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('United States of America','840','US','USA',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('United States Minor Outlying Islands','581','UM','UMI',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Uruguay','858','UY','URY',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Uzbekistan','860','UZ','UZB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Vanuatu','548','VU','VUT',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Venezuela (Bolivarian Republic of)','862','VE','VEN',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Viet Nam','704','VN','VNM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Virgin Islands (British)','92','VG','VGB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Virgin Islands (U.S.)','850','VI','VIR',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Wallis and Futuna','876','WF','WLF',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Western Sahara','732','EH','ESH',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Yemen','887','YE','YEM',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Zambia','894','ZM','ZMB',\(create_time),'ADMIN_USER'),")
        insertstatement.append("('Zimbabwe','716','ZW','ZWE',\(create_time),'ADMIN_USER')")

        print("Insetring Countries: \(insertstatement)")
        
        _ = try? tbl.sqlRows(insertstatement, params: [])
        
    }
}
