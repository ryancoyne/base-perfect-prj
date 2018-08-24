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
    
    func addLedgerAccountTypes() {
        let tbl = LedgerAccountType()
        
        let created_time = CCXServiceClass.sharedInstance.getNow()

        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby,account_group,title,description) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Code', 'Code Creation', 'Customer Code Creation'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Code', 'Code Void', 'Customer Code Void'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','CashOut', 'Cashout','Customer Cashout'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Note', 'Note On Account','Note on a customer account') ")

        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addLedgerTypes() {
        let tbl = LedgerType()
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby,title,description) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Liability', 'Liability Type Account'), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Asset', 'Asset Type Account') ")

        _ = try? tbl.sqlRows(checkuser, params: [])

    }
    
    func addLedgerAccounts() {
        
        let tbl = LedgerAccount()
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby,ledger_account_type_id,title,description) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)',1,'Code Creation', 'Customer Code Creation') ")
        
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }
    
    func addPOS() {
        let tbl = POS()

        let created_time = CCXServiceClass.sharedInstance.getNow()
        
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
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
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

    
    func addCashoutGroup() {
        
        let usa = Country()
        try? usa.find(["code_alpha_2":"US"])
        
        let singapore = Country()
        try? singapore.find(["code_alpha_2":"SG"])
        
        let tbl = CashoutGroup()

        let created_time = CCXServiceClass.sharedInstance.getNow()

        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, group_name,description, country_id, picture_url, display_order, display) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Prepaid Card','This card allows users to purchase anything using the giftcard.', \(usa.id!),'', 1, true), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Gift Card','This card allows users to purchase from specific retailers using the giftcard.', \(usa.id!),'',2, true), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Donate','This allows the user to donate to a specific cause.', \(usa.id!),'',3, true), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Bucket Coin','This is the cryptocurrency for the Bucket users.', \(usa.id!),'',4, true),")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','TopUp','', \(singapore.id!),'',1, true),")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Bucket Coin','This is the cryptocurrency for the Bucket users.', \(singapore.id!),'',2, true), ")
        checkuser.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)','Donate','', \(singapore.id!),'',3, true)")

        print("Adding cashout groups: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }

    func addCashoutOption() {

        let created_time = CCXServiceClass.sharedInstance.getNow()
        
        let usa = Country()
        try? usa.find(["code_alpha_2":"US"])
        
        let singapore = Country()
        try? singapore.find(["code_alpha_2":"SG"])

        let usa_cg = CashoutGroup()
        
        var ussql = ""
        let uscg = try? usa_cg.sqlRows("SELECT * FROM cashout_group WHERE country_id = \(usa.id!) ORDER BY display_order DESC ", params: [])
        for i in uscg! {
            switch i.data.cashoutGroupDic.group_name {
            case "Prepaid Card"?:
                // card 1
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 1, ")
                ussql.append("'Visa',")
                ussql.append("'https://visa.com', ")
                ussql.append("'The VISA prepaid card may be used anywhere online!', ")
                ussql.append("'Come join the VISA family and use this card worldwide!', ")
                ussql.append("'https://usa.visa.com/content/dam/VCOM/nav-assets/logo.png', ")
                ussql.append("50.00,0,true),")
                // card 2
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 2, ")
                ussql.append("'MasterCard',")
                ussql.append("'https://mastercard.com', ")
                ussql.append("'The MasterCard prepaid card may be used anywhere online!', ")
                ussql.append("'Come join the MasterCard family and use this card worldwide!', ")
                ussql.append("'https://www.mastercard.us/etc/designs/mccom/en-us/jcr:content/global/logo.img.png/1472151229727.png', ")
                ussql.append("50.00,0,true),")
                break
            case "Gift Card"?:
                // card 1
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 1, ")
                ussql.append("'Amazon',")
                ussql.append("'https://amazon.com',")
                ussql.append("'Amazon holds the world at your fingertips.',")
                ussql.append("'Amazon is the largest onine retailer in the world.  Use your Amazon card here!',")
                ussql.append("'https://content.blackhawknetwork.com/gcmimages/product/large/5360.jpg',")
                ussql.append("50.00,0,true),")
                // card 2
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 2, ")
                ussql.append("'Target',")
                ussql.append("'https://target.com',")
                ussql.append("'Target is the store with the big red dot.',")
                ussql.append("'Target is a department store with a little bit of everything!',")
                ussql.append("'https://content.blackhawknetwork.com/gcmimages/product/large/7039.jpg',")
                ussql.append("50.00,0,true),")
                // card 3
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 3, ")
                ussql.append("'ThinkGeek',")
                ussql.append("'https://thinkgeek.com',")
                ussql.append("'Fun things for geeks',")
                ussql.append("'Want to buy an amazing gift for a geek?  Get it here!',")
                ussql.append("'https://content.blackhawknetwork.com/gcmimages/product/large/81112.png',")
                ussql.append("50.00,0,true),")
                // card 4
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 4, ")
                ussql.append("'Whole Foods',")
                ussql.append("'https://wholefoods.com',")
                ussql.append("'Want good food?',")
                ussql.append("'Whole Foods provides a wholistic approach to feed.',")
                ussql.append("'https://content.blackhawknetwork.com/gcmimages/product/large/82068.png',")
                ussql.append("50.00,0,true),")
                // card 5
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 5, ")
                ussql.append("'The Cheesecake Factory',")
                ussql.append("'https://www.thecheesecakefactory.com',")
                ussql.append("'Want Cheesecake?',")
                ussql.append("'The Cheesecake Factory creates cheesecake masterpieces!',")
                ussql.append("'https://content.blackhawknetwork.com/gcmimages/product/large/6230.jpg',")
                ussql.append("50.00,0,true),")
                // card 6
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 6, ")
                ussql.append("'Ruby Tuesday',")
                ussql.append("'https://www.rubytuesday.com',")
                ussql.append("'Eat here!',")
                ussql.append("'Hungry on Tuesday?  Come here and join us for dinner.',")
                ussql.append("'https://content.blackhawknetwork.com/gcmimages/product/large/81244.png',")
                ussql.append("50.00,0,true),")

                break
            case "Donate"?:
                // card 1
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 1, ")
                ussql.append("'Heifer International',")
                ussql.append("'www.heifer.org',")
                ussql.append("'Heifer International works with communities to create income, empower women, care for the Earth, and ultimately end world hunger and poverty',")
                ussql.append("'Heifer International’s mission is to end hunger and poverty while caring for the Earth. For more than 70 years, we have provided livestock and environmentally sound agricultural training to improve the lives of those who struggle daily for reliable sources of food and income. We currently work in 25 countries, including the United States, to help families and communities become self-reliant.',")
                ussql.append("'heifer_small.png',")
                ussql.append("50.00,0,true),")
                // card 2
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 2, ")
                ussql.append("'Boys and Girls Club of Fayetteville',")
                ussql.append("'www.fayettevillekids.org',")
                ussql.append("'We are a resource for families to improve the quality of their lives through the development of youth in a safe environment.',")
                ussql.append("'The Donald W. Reynolds Boys & Girls Club is a non-profit 501 (C)(3) organization currently serving over 10,000 community members per year through memberships, special events, facility reservations and drop-in business. Formerly known as the Fayetteville Youth Center, the Club over 75 years of service to youth and families in the local community.',")
                ussql.append("'bgca-fayetteville_small.png',")
                ussql.append("50.00,0,true),")
                // card 3
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 3, ")
                ussql.append("'CASA of Northwest Arkansas',")
                ussql.append("'www.nwacasa.org',")
                ussql.append("'Court Appointed Special Advocates of Northwest Arkansas provides compassionate volunteers who advocate for abused and neglected children.',")
                ussql.append("'In essence, Court Appointed Special Advocates of Northwest Arkansas recruits, trains, and supervises volunteers who provide one-on-one advocacy for abused children and their families. Our CASA volunteers assist children by stabilizing their lives and moving them through the foster care system. CASAs are responsible for assessing the needs of the victims, making referrals for services (counseling, speech/occupational/physical therapy, educational interventions, medical and dental care) and making sure the emotional and physical needs of children are being met while in care.',")
                ussql.append("'casa-small.png',")
                ussql.append("50.00,0,true),")
                // card 4
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 4, ")
                ussql.append("'Dress for Success of NW Arkansas',")
                ussql.append("'www.dfsnwa.org',")
                ussql.append("'Dress for Success Northwest Arkansas helps empower women toward economic independence by providing a network of support, professional attire, and programs that help them thrive in work and in life.',")
                ussql.append("'Dress for Success Northwest Arkansas helps empower women toward economic independence by providing a network of support, professional attire, and programs that help her secure employment, retain her job, grow her career, provide for her family and improve their lives.  We offer long-lasting solutions the enable women to break the cycle of poverty.',")
                ussql.append("'dress%20for%20success_small.png',")
                ussql.append("50.00,0,true),")
                // card 5
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 5, ")
                ussql.append("'KUAF',")
                ussql.append("'kuaf.com',")
                ussql.append("'KUAF 91.3 FM is northwest and Western Arkansas’ NPR affiliate and listener-supported radio station. We serve a 14-county area, with a population of 600,000, with NPR news programming.',")
                ussql.append("'KUAF is northwest and western Arkansas’ NPR affiliate and listener-supported radio station. Owned by the University of Arkansas, KUAF has grown from “The 10-Watt Wonder” in 1973 to the 100,000-watt station it is today. We’ve been this area’s NPR affiliate for 33 years and have changed and grown along with the region, while also holding tight to our roots. We serve a 14-county area, with a population of 600,000, with NPR news programming - news that is highly-researched and vetted and is presented with insight and civil conversation. In today’s political climate, this kind of news programming is more important now than ever before. But more than just news, KUAF is unique in our area as the sole public radio station – and is unique in the breadth and variety of local programming offered. KUAF produces or airs 10 locally-produced programs! Very few other stations of this size produce this much local content – from the Community Spotlight Series with Pete Hartman to local news casts every morning to our daily, news magazine Ozarks at Large,hosted by Kyle Kellams. With the explosive growth in population of our area, KUAF aims to serve not just as a source for news and entertainment, but also as an anchor and introduction to the culture of our region. From The Pickin’ Post, The Generic Blues Show, and Shades of Jazz, plus the hundreds of local events featured in public service announcements and performances of local favorites in the Firmin-Garner performance studio, KUAF reflects the community it serves. We have heard from many listeners new to the area, that listening to KUAF helped them get a better understanding of their new home – from the local news to cultural coverage to the spirit of philanthropy that makes Northwest Arkansas so outstanding.',")
                ussql.append("'kuaf-small.png',")
                ussql.append("50.00,0,true),")
                // card 6
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 6, ")
                ussql.append("'Kendrick Fincher Foundation',")
                ussql.append("'kendrickfincher.org',")
                ussql.append("'Mission: Promote proper hydration and prevent heat illness through education and supporting activities. Vision: Expand national awareness and education to save lives.',")
                ussql.append("'Mission: Promote proper hydration and prevent heat illness through  education and supporting activities.  Vision: Expand national awareness and education to save lives.  Education and Supporting Activities: Be Smart. BeeHydrated! - Presentations to school aged children on the importance of proper hydration Beat the Heat - Presentations to athletes, coaches and parents on proper hydration and heat illness prevention Distribution of squeeze bottles and educational pamphlets to support our educational presentations Representation at health fairs to educate the public about our mission and activities Community involvement in support of our mission by providing “cool huts”—misting tents with free ice water—at various outdoor public events. Annual youth run in Rogers, AR, to reinforce our mission and help children and the community learn about the importance of proper hydration and physical fitness in a fun environment. Partnerships with other sports injury prevention and wellness organizations Web presence that allows for regional and national reach Developing education programs for all ages including senior adults and industrial workforce',")
                ussql.append("'kendrick%20fincher_small.png',")
                ussql.append("50.00,0,true),")

                break
            case "Bucket Coin"?:
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 1, ")
                ussql.append("'Bucket Coin',")
                ussql.append("'https://buckettechnologies.com',")
                ussql.append("'BUX: Our Crypto Coin',")
                ussql.append("'Jump into the Crypto world!  Buy you BUX today.',")
                ussql.append("'',")
                ussql.append("50.00,0,true),")
                break
            default:
                break

            }
        }
        
        let sgcg = try? usa_cg.sqlRows("SELECT * FROM cashout_group WHERE country_id = \(singapore.id!) ORDER BY display_order DESC ", params: [])
        for i in sgcg! {
            switch i.data.cashoutGroupDic.group_name {
            case "TopUp":
                // card 1
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 1, ")
                ussql.append("'TopUp',")
                ussql.append("'https://www.ezetop.com/countries/asia/singapore',")
                ussql.append("'TopUp',")
                ussql.append("'TopUp Your Account',")
                ussql.append("'',")
                ussql.append("50.00,0,true),")
                break
            case "Donate":
                // card 1
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 1, ")
                ussql.append("'Donate',")
                ussql.append("'',")
                ussql.append("'Donate to the cause',")
                ussql.append("'Help make the community strong and tdonate today!',")
                ussql.append("'',")
                ussql.append("50.00,0,true),")
                break
            case "Bucket Coin":
                ussql.append(" ('\(created_time)','\(CCXDefaultUserValues.user_server)', \(i.data.id!), 1, 1, ")
                ussql.append("'Bucket Coin',")
                ussql.append("'https://buckettechnologies.com',")
                ussql.append("'BUX: Our Crypto Coin',")
                ussql.append("'Jump into the Crypto world!  Buy you BUX today.',")
                ussql.append("'',")
                ussql.append("50.00,0,true),")
                break
            default:
                break
                
            }
        }
        
        // remove the last comma from the groups
        ussql.removeLast()
        
        let tbl = CashoutOption()
        
        var checkuser = "INSERT INTO \(tbl.table()) "
        checkuser.append("(created, createdby, group_id, form_id, display_order, ")
        checkuser.append("name, website, description, long_description, pictureurl, ")
        checkuser.append("minimum, maximum, display) ")
        checkuser.append(" VALUES ")
        checkuser.append(ussql)
        
        print("Adding cashout options: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])
        
    }

    func addForms() {
        
        let tbl = Form()
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
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
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
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
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
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
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
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
        
        let create_time = CCXServiceClass.sharedInstance.getNow()

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
