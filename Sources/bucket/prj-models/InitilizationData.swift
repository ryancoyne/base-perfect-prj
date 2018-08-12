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
    
//    static let createdby  = "AUTO_CREATED_USER"
//    static let modifiedby = "AUTO_MODIFIED_USER"
//    static let deletedby  = "AUTO_DELETED_USER"
    
    static let sharedInstance = InitializeData()
    
    func addPOS() {
        let tbl = POS()

        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name,model) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Clover', 'C300'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Clover','Clover Station') ")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        
    }

    func addContactTypes() {
        
        let tbl = ContactType()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name,description) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)' ,'billing','This is the main billing contact for the account.'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','manager','This is a manager for the account.'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','admin','This is the main billing contact for the account.'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','billing','This is an administrative contact for the account.')")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }

    
    func addCashoutTypes() {
        
        let tbl = CashoutTypes()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name,description) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Open Loop Gift Card','This card allows users to purchase anything using the giftcard.'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Closed Loop Gift Card','This card allows users to purchase from specific retailers using the giftcard.'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Donate','This allows the user to donate to a specific cause.'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Bucket Coin','This is the cryptocurrency for the Bucket users.')")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }
    
    func addForms() {
        
        let tbl = Form()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name, title) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','BUX Coin', 'BUX'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','US Open Loop', 'Prepaid Card'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','US Closed Loop', 'Gift Card'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','US Donation', 'Donate') ")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }
    
    func addFormFieldType() {

        let tbl = FormFieldType()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Checkbox'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Text'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Number'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','E-Mail'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Phone'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Currency')")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addFormField() {

        let tbl = FormField()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, name, type_id, length, is_required, needs_confirmation) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Full Name', 2, 25, TRUE, FALSE), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Email Address', 4, 50, TRUE, TRUE), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Keep me updated with new offers!', 1, 1, FALSE, FALSE) ")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addFormFields() {

        let tbl = FormFields()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, form_id, field_id, display_order) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 1, 1, 1), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 1, 2, 2), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 1, 3, 3), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 2, 1, 1), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 2, 2, 2), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 2, 3, 3), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 3, 1, 1), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 3, 2, 2), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 3, 3, 3), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 4, 1, 1), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 4, 2, 2), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', 4, 3, 3) ")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addCountryCodes() {
        let tbl = Country()
        
        let create_time = Int(Date().timeIntervalSince1970)

        var insertstatement = "INSERT INTO \(tbl.table())"
        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
        insertstatement.append(" VALUES ")
        insertstatement.append("('Afghanistan','4','AF','AFG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Åland Islands','248','AX','ALA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Albania','8','AL','ALB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Algeria','12','DZ','DZA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('American Samoa','16','AS','ASM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Andorra','20','AD','AND',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Angola','24','AO','AGO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Anguilla','660','AI','AIA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Antarctica','10','AQ','ATA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Antigua and Barbuda','28','AG','ATG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Argentina','32','AR','ARG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Armenia','51','AM','ARM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Aruba','533','AW','ABW',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Australia','36','AU','AUS',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Austria','40','AT','AUT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Azerbaijan','31','AZ','AZE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bahamas','44','BS','BHS',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bahrain','48','BH','BHR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bangladesh','50','BD','BGD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Barbados','52','BB','BRB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Belarus','112','BY','BLR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Belgium','56','BE','BEL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Belize','84','BZ','BLZ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Benin','204','BJ','BEN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bermuda','60','BM','BMU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bhutan','64','BT','BTN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bolivia (Plurinational State of)','68','BO','BOL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bonaire, Sint Eustatius and Saba','535','BQ','BES',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bosnia and Herzegovina','70','BA','BIH',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Botswana','72','BW','BWA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bouvet Island','74','BV','BVT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Brazil','76','BR','BRA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('British Indian Ocean Territory','86','IO','IOT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Brunei Darussalam','96','BN','BRN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Bulgaria','100','BG','BGR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Burkina Faso','854','BF','BFA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Burundi','108','BI','BDI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cabo Verde','132','CV','CPV',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cambodia','116','KH','KHM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cameroon','120','CM','CMR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Canada','124','CA','CAN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cayman Islands','136','KY','CYM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Central African Republic','140','CF','CAF',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Chad','148','TD','TCD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Chile','152','CL','CHL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('China','156','CN','CHN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Christmas Island','162','CX','CXR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cocos (Keeling) Islands','166','CC','CCK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Colombia','170','CO','COL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Comoros','174','KM','COM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Congo','178','CG','COG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Congo (Democratic Republic of the)','180','CD','COD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cook Islands','184','CK','COK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Costa Rica','188','CR','CRI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Côte d Ivoire','384','CI','CIV',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Croatia','191','HR','HRV',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cuba','192','CU','CUB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Curaçao','531','CW','CUW',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Cyprus','196','CY','CYP',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Czechia','203','CZ','CZE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Denmark','208','DK','DNK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Djibouti','262','DJ','DJI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Dominica','212','DM','DMA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Dominican Republic','214','DO','DOM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Ecuador','218','EC','ECU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Egypt','818','EG','EGY',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('El Salvador','222','SV','SLV',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Equatorial Guinea','226','GQ','GNQ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Eritrea','232','ER','ERI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Estonia','233','EE','EST',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Eswatini','748','SZ','SWZ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Ethiopia','231','ET','ETH',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Falkland Islands (Malvinas)','238','FK','FLK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Faroe Islands','234','FO','FRO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Fiji','242','FJ','FJI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Finland','246','FI','FIN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('France','250','FR','FRA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('French Guiana','254','GF','GUF',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('French Polynesia','258','PF','PYF',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('French Southern Territories','260','TF','ATF',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Gabon','266','GA','GAB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Gambia','270','GM','GMB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Georgia','268','GE','GEO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Germany','276','DE','DEU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Ghana','288','GH','GHA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Gibraltar','292','GI','GIB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Greece','300','GR','GRC',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Greenland','304','GL','GRL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Grenada','308','GD','GRD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Guadeloupe','312','GP','GLP',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Guam','316','GU','GUM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Guatemala','320','GT','GTM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Guernsey','831','GG','GGY',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Guinea','324','GN','GIN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Guinea-Bissau','624','GW','GNB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Guyana','328','GY','GUY',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Haiti','332','HT','HTI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Heard Island and McDonald Islands','334','HM','HMD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Holy See','336','VA','VAT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Honduras','340','HN','HND',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Hong Kong','344','HK','HKG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Hungary','348','HU','HUN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Iceland','352','IS','ISL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('India','356','IN','IND',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Indonesia','360','ID','IDN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Iran (Islamic Republic of)','364','IR','IRN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Iraq','368','IQ','IRQ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Ireland','372','IE','IRL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Isle of Man','833','IM','IMN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Israel','376','IL','ISR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Italy','380','IT','ITA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Jamaica','388','JM','JAM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Japan','392','JP','JPN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Jersey','832','JE','JEY',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Jordan','400','JO','JOR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Kazakhstan','398','KZ','KAZ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Kenya','404','KE','KEN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Kiribati','296','KI','KIR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Korea (Democratic Peoples Republic of)','408','KP','PRK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Korea (Republic of)','410','KR','KOR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Kuwait','414','KW','KWT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Kyrgyzstan','417','KG','KGZ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Lao Peoples Democratic Republic','418','LA','LAO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Latvia','428','LV','LVA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Lebanon','422','LB','LBN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Lesotho','426','LS','LSO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Liberia','430','LR','LBR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Libya','434','LY','LBY',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Liechtenstein','438','LI','LIE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Lithuania','440','LT','LTU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Luxembourg','442','LU','LUX',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Macao','446','MO','MAC',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Macedonia (the former Yugoslav Republic of)','807','MK','MKD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Madagascar','450','MG','MDG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Malawi','454','MW','MWI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Malaysia','458','MY','MYS',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Maldives','462','MV','MDV',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Mali','466','ML','MLI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Malta','470','MT','MLT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Marshall Islands','584','MH','MHL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Martinique','474','MQ','MTQ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Mauritania','478','MR','MRT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Mauritius','480','MU','MUS',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Mayotte','175','YT','MYT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Mexico','484','MX','MEX',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Micronesia (Federated States of)','583','FM','FSM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Moldova (Republic of)','498','MD','MDA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Monaco','492','MC','MCO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Mongolia','496','MN','MNG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Montenegro','499','ME','MNE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Montserrat','500','MS','MSR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Morocco','504','MA','MAR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Mozambique','508','MZ','MOZ',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Myanmar','104','MM','MMR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Namibia','516','NA','NAM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Nauru','520','NR','NRU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Nepal','524','NP','NPL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Netherlands','528','NL','NLD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('New Caledonia','540','NC','NCL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('New Zealand','554','NZ','NZL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Nicaragua','558','NI','NIC',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Niger','562','NE','NER',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Nigeria','566','NG','NGA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Niue','570','NU','NIU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Norfolk Island','574','NF','NFK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Northern Mariana Islands','580','MP','MNP',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Norway','578','NO','NOR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Oman','512','OM','OMN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Pakistan','586','PK','PAK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Palau','585','PW','PLW',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Palestine, State of','275','PS','PSE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Panama','591','PA','PAN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Papua New Guinea','598','PG','PNG',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Paraguay','600','PY','PRY',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Peru','604','PE','PER',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Philippines','608','PH','PHL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Pitcairn','612','PN','PCN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Poland','616','PL','POL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Portugal','620','PT','PRT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Puerto Rico','630','PR','PRI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Qatar','634','QA','QAT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Réunion','638','RE','REU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Romania','642','RO','ROU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Russian Federation','643','RU','RUS',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Rwanda','646','RW','RWA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saint Barthélemy','652','BL','BLM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saint Helena, Ascension and Tristan da Cunha','654','SH','SHN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saint Kitts and Nevis','659','KN','KNA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saint Lucia','662','LC','LCA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saint Martin (French part)','663','MF','MAF',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saint Pierre and Miquelon','666','PM','SPM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saint Vincent and the Grenadines','670','VC','VCT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Samoa','882','WS','WSM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('San Marino','674','SM','SMR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Sao Tome and Principe','678','ST','STP',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Saudi Arabia','682','SA','SAU',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Senegal','686','SN','SEN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Serbia','688','RS','SRB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Seychelles','690','SC','SYC',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Sierra Leone','694','SL','SLE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Singapore','702','SG','SGP',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Sint Maarten (Dutch part)','534','SX','SXM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Slovakia','703','SK','SVK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Slovenia','705','SI','SVN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Solomon Islands','90','SB','SLB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Somalia','706','SO','SOM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('South Africa','710','ZA','ZAF',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('South Georgia and the South Sandwich Islands','239','GS','SGS',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('South Sudan','728','SS','SSD',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Spain','724','ES','ESP',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Sri Lanka','144','LK','LKA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Sudan','729','SD','SDN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Suriname','740','SR','SUR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Svalbard and Jan Mayen','744','SJ','SJM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Sweden','752','SE','SWE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Switzerland','756','CH','CHE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Syrian Arab Republic','760','SY','SYR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Taiwan, Province of China','158','TW','TWN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Tajikistan','762','TJ','TJK',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Tanzania, United Republic of','834','TZ','TZA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Thailand','764','TH','THA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Timor-Leste','626','TL','TLS',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Togo','768','TG','TGO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Tokelau','772','TK','TKL',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Tonga','776','TO','TON',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Trinidad and Tobago','780','TT','TTO',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Tunisia','788','TN','TUN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Turkey','792','TR','TUR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Turkmenistan','795','TM','TKM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Turks and Caicos Islands','796','TC','TCA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Tuvalu','798','TV','TUV',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Uganda','800','UG','UGA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Ukraine','804','UA','UKR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('United Arab Emirates','784','AE','ARE',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('United Kingdom of Great Britain and Northern Ireland','826','GB','GBR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('United States of America','840','US','USA',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('United States Minor Outlying Islands','581','UM','UMI',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Uruguay','858','UY','URY',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Uzbekistan','860','UZ','UZB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Vanuatu','548','VU','VUT',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Venezuela (Bolivarian Republic of)','862','VE','VEN',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Viet Nam','704','VN','VNM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Virgin Islands (British)','92','VG','VGB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Virgin Islands (U.S.)','850','VI','VIR',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Wallis and Futuna','876','WF','WLF',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Western Sahara','732','EH','ESH',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Yemen','887','YE','YEM',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Zambia','894','ZM','ZMB',\(create_time),'\(CCXDefaultUserValues.user_server)'),")
        insertstatement.append("('Zimbabwe','716','ZW','ZWE',\(create_time),'\(CCXDefaultUserValues.user_server)')")

        print("Insetring Countries: \(insertstatement)")
        
        _ = try? tbl.sqlRows(insertstatement, params: [])
        
    }
}
