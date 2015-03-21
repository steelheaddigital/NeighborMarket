# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

site_settings = SiteSetting.instance.update(
  :site_name => "Neighbor Market",
  :time_zone => "Pacific Time (US & Canada)"
)

User.delete_all
user = User.new(
  :username => "manager",
  :email => "email@somesite.com",
  :password   => "Abc123!", 
)
user.add_role('manager')

user.skip_confirmation!
user.save(:validate => false)

fresh_produce = TopLevelCategory.new(
  :name => 'Fresh Produce',
  :description => 'Fresh Produce'
)
fresh_produce.second_level_categories.build([
    { :name => 'Roots',
      :description => 'Roots'},
    { :name => 'Greens',
      :description => 'Greens'},
    { :name => 'Fruits',
      :description => 'Fruits'},
    { :name => 'Squash',
      :description => 'Squash'},
    { :name => 'Herbs',
      :description => 'Herbs'},
    { :name => 'Other Fresh Produce',
      :description => 'Other Fresh Produce'}
  ]
)
fresh_produce.save

animal_products = TopLevelCategory.new(
  :name => 'Animal Products',
  :description => 'Animal Products'
)
animal_products.second_level_categories.build([
    { :name => 'Meat',
      :description => 'Meat'},
    { :name => 'Dairy',
      :description => 'Dairy'},
    { :name => 'Eggs',
      :description => 'Eggs'}
  ]
)
animal_products.save

prepared_food = TopLevelCategory.new(
  :name => 'Prepared Food',
  :description => 'Prepared Food'
)
prepared_food.second_level_categories.build([
    { :name => 'Baked Goods',
      :description => 'Baked Goods'},
    { :name => 'Soup',
      :description => 'Soup'},
    { :name => 'Meals',
      :description => 'Meals'},
    { :name => 'Snacks',
      :description => 'Snacks'},
    { :name => 'Drinks',
      :description => 'Drinks'},
    { :name => 'Other Prepared Food',
      :description => 'Other Prepared Food'},
    { :name => 'Condiments',
      :description => 'Condiments'}
  ]
)
prepared_food.save

preserved_food = TopLevelCategory.new(
  :name => 'Preserved Food',
  :description => 'Preserved Food'
)
preserved_food.second_level_categories.build([
    { :name => 'Pickles',
      :description => 'Pickles'},
    { :name => 'Jams, Jellies, and Fruit Preserves',
      :description => 'Jams, Jellies, and Preserves'},
    { :name => 'Canned Fruits and Vegetables',
      :description => 'Canned Fruits and Vegetables'},
    { :name => 'Dried Food',
      :description => 'Dried Food'},
    { :name => 'Other Preserved Food',
      :description => 'Other Preserved Food'}
  ]
)
preserved_food.save

household_goods = TopLevelCategory.new(
  :name => 'Household Goods',
  :description => 'Household Goods'
)
household_goods.second_level_categories.build([
    { :name => 'Cleaning Supplies',
      :description => 'Cleaning Supplies'},
    { :name => 'Personal Care Products',
      :description => 'Personal Care'},
    { :name => 'Other Household Goods',
      :description => 'Other Household Goods'}
  ]
)
household_goods.save

durable_goods = TopLevelCategory.new(
  :name => 'Durable Crafts',
  :description => 'Durable Crafts'
)
durable_goods.second_level_categories.build([
    { :name => 'Ceramics',
      :description => 'Ceramics'},
    { :name => 'Wood Products',
      :description => 'Wood Products'},
    { :name => 'Textiles',
      :description => 'Textiles'},
    { :name => 'Metal Products',
      :description => 'Metal Products'},
    { :name => 'Fine Art',
      :description => 'Fine Art'},
    { :name => 'Other Durable Crafts',
      :description => 'Other Durable Crafts'}   
  ]
)
durable_goods.save

PriceUnit.create(:name => "each")
PriceUnit.create(:name => "ounce")
PriceUnit.create(:name => "pound")
PriceUnit.create(:name => "quart")
PriceUnit.create(:name => "gallon")
PriceUnit.create(:name => "jar")

about = %[<p>We help local producers sell directly to consumers connecting the community to the rich resources right here in our backyards, front lawns, kitchens, and neighborhoods.</p>
<h2>How It Works</h2>
<ol>
<li>complete a buyer and/or seller profile here on the website by clicking the links at the top of the page. It only takes a few minutes before you can post your goods for sale and purchase goods from your neighbors.</li>
<li>Do your shopping on the website  at any time throughout the two week order cycle.  </li>
<li>At the end of each two week order cycle, drop off your sold goods and pick up your purchased products at our drop point.</li>
</ol>
<h2>Payments</h2>
Payments are managed between each buyer and seller directly at the time of pickup.
<h2>Help</h2>
If you are having trouble with the website or simply have questions, you can contact the site manager using our <a href="/contact?layout=info">contact form</a>]

terms = %[<p>PLEASE READ THIS AGREEMENT CAREFULLY. IT CONTAINS IMPORTANT INFORMATION ABOUT YOUR RIGHTS AND OBLIGATIONS.</p>
<p>TERMS OF USE</p>
<p>1. GENERAL</p>
<p>This website provides services, programs and computer servers, including but not limited to local food sourcing, marketing, and forums. (All such services are referred to collectively herein as the “Services.") By accessing or using the Services, you are a "user" and you accept and agree to the terms below (the "Terms of Use" or "TOU") as a legal contract between you and the operator of the website. The TOU include and incorporate additional terms ("guidelines") applicable to particular categories or services available on the Services as set forth to users upon access to such categories or services. The website operator may post changes to the TOU at any time, and any such changes will be applicable to all subsequent access to or use of the Services.</p>
<p>If you do not accept and agree to all provisions of the TOU, now or in the future, you may reject the TOU by immediately terminating all access and use of the Services, in which case any continuing access or use of the Services is unauthorized.</p>
<p>You are also required to comply with, and to ensure compliance with, all laws, ordinances and regulations applicable to your activities on the Services.</p>
<p>The Services is intended and designed for users 13 years of age and older, and access or use by anyone younger is not authorized.</p>
<p>The TOU grant you a limited, revocable, nonexclusive license to access the Services and use the Services, in whole or in part, including but not limited to intellectual property therein, solely in compliance with the TOU.</p>
<p>2. MODERATION</p>
<p>The website operator has the right, but not the obligation, to regulate content (which includes but is not limited to postings, text, code, images, video, binary files, ads, accounts, account information, flags, emails, messages and any other user communications ("content")) posted to, stored on or transmitted via the Services by any user (or any other third party in any manner); to regulate conduct (including but not limited to any authorized or unauthorized access to or use of the Services) by any user (or any other third party in any manner); and to enforce the TOU, for any reason and in any manner or by any means that the website operator, in its sole discretion, deems necessary or appropriate (including but not limited to automated and manual screening, blocking, filtering, exclusion from index pages, exclusion from search results, requiring the use of an application programming interface (API), requiring the use of a bulk posting interface, authorization, verification, and the deletion and/or termination of content, accounts and/or all or any use or access). The website operator may, in its sole discretion and without notice, start, stop or modify any regulation or enforcement measures at any time. Website operator action or inaction to regulate content or conduct or to enforce against any potential violation of the TOU by any user (or any other third party) does not waive the website operator's right to implement or not implement regulation or enforcement measures with respect to any subsequent or similar content, conduct or potential TOU violation.</p>
<p>You also understand and agree that any action or inaction by the website operator or any of its directors, officers, stockholders, employees, consultants, agents or representatives (collectively, "Representatives") to prevent, restrict, redress or regulate content, or to implement other enforcement measures against any content, conduct or potential TOU violation is undertaken voluntarily and in good faith, and you expressly agree that neither the website operator nor any Representative shall be liable to you or anyone else for any action or inaction to prevent, restrict, redress, or regulate content, or to implement other enforcement measures against any content, conduct or potential violation of the TOU.</p>
<p>Although Representatives may moderate content, conduct and TOU compliance on the Services at the website operator's discretion, Representatives have no authority to make binding commitments, promises or representations to anyone that they or anyone else on behalf of the website operator will "take care" of any alleged problem or complaint, or that they or anyone else on behalf of the website operator will otherwise stop, cure or prevent any problem, content, conduct or purported TOU violation from occurring or recurring. Accordingly, you further agree that any representation (written or verbal) by any Representative (or by anyone else acting on behalf of the website operator or by anyone purportedly acting on behalf of the website operator) that the website operator (including but not limited to any Representative, anyone else acting on behalf of the website operator, or anyone purportedly acting on behalf of the website operator) would or would not prevent, restrict, redress or regulate content (including, without limitation, screen, block, moderate, review, remove, terminate, delete, edit or otherwise stop, cure or exclude any content), or to implement other enforcement measures against any content, conduct or potential or purported TOU violation is superseded by this provision and is nonbinding and unenforceable. Specifically, you agree that the website operator, Representatives and anyone else authorized to act on behalf of the website operator shall in no circumstance be liable as a result of any representation that the website operator, a the website operator Representative or anyone else on behalf of the website operator would or would not restrict or redress any content, conduct or potential or purported TOU violation. This paragraph may not be modified, waived or released except by a written agreement, dated and signed by the website operator and dated and signed by the individual or entity to whom the modification, waiver or release is granted.</p>
<p>The website operator also has the right in its sole discretion to limit, modify, interrupt, suspend or discontinue all or any portions of the Services at any time without notice. The website operator and Representatives shall not be liable for any such limitations, modifications, interruptions, suspensions or discontinuance, or any purported losses, harm or damages arising from or related thereto.</p>
<p>3. CONTENT AND CONDUCT</p>
<p>a. Content</p>
<p>The website operator does not control, is not responsible for and makes no representations or warranties with respect to any user content. You are solely responsible for your access to, use of and/or reliance on any user content. You must conduct any necessary, appropriate, prudent or judicious investigation, inquiry, research and due diligence with respect to any user content.</p>
<p>You are also responsible for any content that you post or transmit and, if you create an account, you are responsible for all content posted or transmitted through or by use of your account.</p>
<p>Content prohibited from the Services includes but is not limited to: (1) illegal content; (2) content in facilitation of the creation, advertising, distribution, provision or receipt of illegal goods or services; (3) offensive content (including, without limitation, defamatory, threatening, hateful or pornographic content); (4) content that discloses another's personal, confidential or proprietary information; (5) false or fraudulent content (including but not limited to false, fraudulent or misleading responses to user ads transmitted via the Services); (6) malicious content (including, without limitation, malware or spyware); (7) content that offers, promotes, advertises, or provides links to posting or auto-posting products or services, account creation or auto-creation products or services, flagging or auto-flagging products or services, bulk telephone numbers, or any other product or service that if utilized with respect to the Services would violate these TOU or the website operator's other legal rights; and (8) content that offers, promotes, advertises or provides links to unsolicited products or services. Other content prohibitions are set forth in guidelines for particular categories or services on the Services and all such prohibitions are expressly incorporated into these TOU as stated in section 1 above.</p>
<p>You automatically grant and assign to the website operator, and you represent and warrant that you have the right to grant and assign to the website operator, a perpetual, irrevocable, unlimited, fully paid, fully sub-licensable (through multiple tiers), worldwide license to copy, perform, display, distribute, prepare derivative works from (including, without limitation, incorporating into other works) and otherwise use any content that you post. You also expressly grant and assign to the website operator all rights and causes of action to prohibit and enforce against any unauthorized copying, performance, display, distribution, use or exploitation of, or creation of derivative works from, any content that you post (including but not limited to any unauthorized downloading, extraction, harvesting, collection or aggregation of content that you post).</p>
<p>You agree to indemnify and hold the website operator and Representatives harmless from and against any third-party claim, cause of action, demand or damages related to or arising out of: (a) content that you post or transmit (including but not limited to content that a third-party deems defamatory or otherwise harmful or offensive); (b) activity that occurs through or by use of your account (including, without limitation, all content posted or transmitted); (c) your use of or reliance on any user content; and (d) your violation of the TOU. This indemnification obligation includes payment of any attorneys' fees and costs incurred by the website operator or Representatives.</p>
<p>b. Conduct</p>
<p>The website operator does not control, is not responsible for and makes no representations or warranties with respect to any user or user conduct. You are solely responsible for your interaction with or reliance on any user or user conduct. You must perform any necessary, appropriate, prudent or judicious investigation, inquiry, research and due diligence with respect to any user or user conduct.</p>
<p>You are also responsible for your own conduct and activities on, through or related to the Services, and, if you create an account on the Services, you are responsible for all conduct or activities on, through or by use of your account.</p>
<p>You agree to indemnify and hold the website operator and Representatives harmless from and against any third-party claim, cause of action, demand or damages related to or arising out of your own conduct or activities on, through or related to the Services or the website operator, and related to or arising out of any conduct or activities on, through or by use of your the Services account, if any. This indemnification obligation includes payment of any attorneys' fees and costs incurred by the website operator or Representatives.</p>
<p>POSTING AND ACCOUNTS</p>
<p>This section 4 applies to all uses and users of the Services, unless the website operator has specifically authorized an exception to a particular term for a particular user in a written agreement. The website operator has sole and absolute discretion to authorize or deny any exception or exceptions to the terms in this section 4.</p>
<p>a. Postings</p>
<p>The Services is intended and designed as a local service. Content that is equally relevant to multiple (i.e., more than one) geographic areas should not be posted on the Services.</p>
<p>Users may not circumvent any technological measure implemented by the website operator to restrict the manner in which content may be posted on the Services or to regulate the manner in which content (including but not limited to email) may be transmitted to other users. This prohibition includes, without limitation, a ban on the use of multiple email addresses (created via an email address generator or otherwise); the use of multiple IP addresses (via proxy servers, modem toggling, or otherwise); CAPTCHA circumvention, automation or outsourcing; multiple and/or fraudulent the Services accounts, including phone-verified accounts; URL shortening, obfuscation or redirection; use of multiple phone lines or phone forwarding for verification; and content obfuscation via HTML techniques, printing text on images, inserting random text or content "spinning."</p>
<p>It is expressly prohibited for any third party to post content to the Services on behalf of another. Users must post content only on their own behalf, and may not permit, enable, induce or encourage any third party to post content for them.</p>
<p>It is expressly prohibited to post content to the Services using any automated means. Users must post all content personally and manually through all steps of the posting process. It is also expressly prohibited for any user to develop, offer, market, sell, distribute or provide an automated means to perform any step of the posting process (in whole or in part). Any user who develops, offers, markets, sells, distributes or provides an automated means to perform any step of the posting process (in whole or in part) shall be responsible and liable to the website operator for each instance of access to the Services (by any user or other third party) using that automated means.</p>
<p>Affiliate marketing is expressly prohibited on the Services. Users may not post content or communicate with any the Services user for purposes of affiliate marketing or in connection with any affiliate marketing system, scheme or program in any manner or under any circumstance.</p>
<p>b. Accounts</p>
<p>A user may maintain and use no more than one account, including a telephone or phone-verified account ("PVA"), to post content. A user specifically may not create or use additional accounts for the purpose of circumventing technological restrictions (security measures) in the posting process or otherwise for posting content in violation of the TOU.</p>
<p>A user may create an account, including a PVA, only on his/her own behalf. A user must not permit, enable, induce or encourage others to create accounts or PVAs for him/her. The creation of accounts or PVAs for others is expressly prohibited.</p>
<p>A user must only use his/her own account or PVA, and may not use any account or PVA of another.</p>
<p>The purchase and sale of accounts, including but not limited to PVAs, is expressly prohibited.</p>
<p>A user must create his/her account or PVA personally and manually and may not create accounts or PVAs by any automated means. Without limitation, this includes the obligation that the user personally and manually solves any CAPTCHA challenge in the account creation process. Further, a user must create any PVA using his/her own valid telephone number. The creation of a PVA using a telephone number that is not the user's own, a telephonic forwarding service or system, or a temporary/disposable telephone number or service is expressly prohibited. The circumvention of any technological restriction or security measure in the account creation or PVA creation process is also expressly prohibited.</p>
<p>5. UNAUTHORIZED ACCESS AND ACTIVITIES</p>
<p>This section 5 applies to all uses and users of the Services, unless the website operator has specifically authorized an exception to a particular term for a particular user in a written agreement. The website operator has sole and absolute discretion to authorize or deny any exception or exceptions to the terms in this section 5.</p>
<p>To maintain the integrity and functionality of the Services for its users, access to the Services and/or activities related to the Services that are harmful to, inconsistent with or disruptive of the Services and/or its users' beneficial use and enjoyment of the Services are expressly unauthorized and prohibited. For example, without limitation:</p>
<p>Any copying, aggregation, display, distribution, performance or derivative use of the Services or any content posted on the Services whether done directly or through intermediaries (including but not limited to by means of spiders, robots, crawlers, scrapers, framing, iframes or RSS feeds) is prohibited. As a limited exception, general purpose Internet search engines and noncommercial public archives will be entitled to access the Services without individual written agreements executed with the website operator that specifically authorize an exception to this prohibition if, in all cases and individual instances: (a) they provide a direct hyperlink to the relevant the Services website, service, forum or content; (b) they access the Services from a stable IP address using an easily identifiable agent; and (c) they comply with the site's robots.txt file; provided however, that the website operator may terminate this limited exception as to any search engine or public archive (or any person or entity relying on this provision to access the Services without their own written agreement executed with the website operator), at any time and in its sole discretion, upon written notice, including, without limitation, by email notice.</p>
<p>Any activities (including but not limited to posting voluminous content) that are inconsistent with use of the Services in compliance with the TOU or that may impair or interfere with the integrity, functionality, performance, usefulness, usability, signal-to-noise ratio or quality of all or any part of the Services in any manner are expressly prohibited.</p>
<p>Any attempt (whether or not successful) to engage in, or to enable, induce, encourage, cause or assist anyone else to engage in, any of the above unauthorized and prohibited access and activities is also expressly prohibited and is a violation of the TOU.</p>
<p>6. USER COMMUNICATIONS, TRANSACTIONS, INTERACTIONS, DISPUTES AND RELATIONS</p>
<p>The website operator and Representatives are not parties to, have no involvement or interest in, make no representations or warranties as to, and have no responsibility or liability with respect to any communications, transactions, interactions, disputes or any relations whatsoever between you and any other user, person or organization ("your interactions with others"). You must conduct any necessary, appropriate, prudent or judicious investigation, inquiry, research or due diligence with respect to your interactions with others.</p>
<p>You agree to indemnify and hold the website operator and Representatives harmless from and against any third-party claim, cause of action, demand or damages related to or arising out of your interactions with others. This indemnification obligation includes payment of any attorneys' fees and costs incurred by the website operator or Representatives.</p>
<p>7. DISCLAIMERS</p>
<p>YOUR ACCESS TO, USE OF AND RELIANCE ON THE WEBSITE AND CONTENT ACCESSED THROUGH THE WEBSITE IS ENTIRELY AT YOUR OWN RISK. THE WEBSITE IS PROVIDED ON AN "AS IS" OR "AS AVAILABLE" BASIS WITHOUT ANY WARRANTIES OF ANY KIND.</p>
<p>ALL EXPRESS AND IMPLIED WARRANTIES (INUBRUDING, WITHOUT LIMITATION, WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT OF PROPRIETARY RIGHTS) ARE EXPRESSLY DISUBRAIMED.</p>
<p>WITHOUT LIMITING THE FOREGOING, THE WEBSITE OPERATOR ALSO DISUBRAIMS ALL WARRANTIES FOR OR WITH RESPECT TO: (a) THE SECURITY, RELIABILITY, TIMELINESS, ACCURACY AND PERFORMANCE OF CONTENT ACCESSED THROUGH THE SITE; (b) COMPUTER WORMS, VIRUSES, SPYWARE, ADWARE AND ANY OTHER MALWARE, MALICIOUS CODE OR HARMFUL CONTENT OR COMPONENTS ACCESSED, RECEIVED OR DISSEMINATED THROUGH, RELATED TO OR AS A RESULT OF THE WEBSTE OR CONTENT ACCESSED THROUGH THE WEBSITE; (c) ANY TRANSACTIONS OR POTENTIAL TRANSACTIONS, GOODS OR SERVICES PROMISED OR EXCHANGED, INFORMATION OR ADVICE OFFERED OR EXCHANGED, OR OTHER CONTENT, INTERACTIONS, REPRESENTATIONS OR COMMUNICATIONS THROUGH, RELATED TO OR AS A RESULT OF USE OF THE WEBSITE OR CONTENT ACCESSED THROUGH THE WEBSITE (INUBRUDING, WITHOUT LIMITATION, ACCESSED THROUGH ANY LINKS ON THE WEBSITE OR IN CONTENT).</p>
<p>THESE DISCLAIMERS SHALL APPLY TO THE FULLEST EXTENT PERMITTED BY LAW.</p>
<p>Some jurisdictions do not allow disclaimer of implied warranties. In such jurisdictions, some of the foregoing disclaimers as to implied warranties may not apply.</p>
<p>8. LIMITATIONS OF LIABILITY</p>
<p>THE WEBSITE OPERATOR AND REPRESENTATIVES SHALL UNDER NO CIRCUMSTANCES BE LIABLE FOR ANY ACCESS TO, USE OF OR RELIANCE ON THE WEBSITE OR CONTENT ACCESSED THROUGH THE WEBSITE BY YOU OR ANYONE ELSE, OR FOR ANY TRANSACTIONS, COMMUNICATIONS, INTERACTIONS, DISPUTES OR RELATIONS BETWEEN YOU AND ANY OTHER PERSON OR ORGANIZATION ARISING OUT OF OR RELATED TO THE WEBSITE OR CONTENT ACCESSED THROUGH THE WEBSITE, INUBRUDING BUT NOT LIMITED TO LIABILITY FOR INJUNCTIVE RELIEF AS WELL AS FOR ANY HARM, INJURY, LOSS OR DAMAGES OF ANY KIND INCURRED BY YOU OR ANYONE ELSE (INUBRUDING, WITHOUT LIMITATION, DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, STATUTORY, EXEMPLARY OR PUNITIVE DAMAGES, EVEN IF THE WEBSITE OPERATOR OR ANY REPRESENTATIVE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES). THIS LIMITATION OF LIABILITY APPLIES REGARDLESS OF, BUT IS NOT RESTRICTED TO, WHETHER THE ALLEGED LIABILITY, HARM, INJURY, LOSS OR DAMAGES AROSE FROM AUTHORIZED OR UNAUTHORIZED ACCESS TO OR USE OF THE WEBSITE OR CONTENT ACCESSED THROUGH THE WEBSITE; ANY INABILITY TO ACCESS OR USE THE WEBSITE OR CONTENT ACCESSED THROUGH THE WEBSITE; OR ANY REMOVAL, DELETION, LIMITATION, MODIFICATION, INTERRUPTION, SUSPENSION, DISCONTINUANCE OR TERMINATION OF THE WEBSITE OR CONTENT ACCESSED THROUGH THE WEBSITE.</p>
<p>THESE LIMITATIONS SHALL ALSO APPLY WITH RESPECT TO DAMAGES RESULTING FROM ANY TRANSACTIONS OR POTENTIAL TRANSACTIONS, GOODS OR SERVICES PROMISED OR EXCHANGED, INFORMATION OR ADVICE OFFERED OR EXCHANGED, OR OTHER CONTENT, INTERACTIONS, REPRESENTATIONS, COMMUNICATIONS OR RELATIONS THROUGH, RELATED TO OR AS A RESULT OF THE WEBSITE OR CONTENT ACCESSED THROUGH THE WEBSITE (INUBRUDING, WITHOUT LIMITATION, ANY LINKS ON THE WEBSITE AND LINKS IN CONTENT ACCESSED THROUGH THE WEBSITE).</p>
<p>You hereby release the website operator and each of the Representatives, and their respective subsidiaries, affiliates, successors, predecessors, assigns, heirs, service providers and suppliers, from all claims, demands and damages of every kind and nature, known and unknown, direct and indirect, suspected and unsuspected, disclosed and undisclosed, arising out of or in any way related to the Services or content accessed through the Services, or any interactions with others arising out of or related to the Services or content accessed through the Services, and you expressly waive the provisions of California Civil Code Section 1542 (and any similar laws in other jurisdictions), which provides: "A general release does not extend to claims which the creditor does not know or suspect to exist in his favor at the time of executing the release, which, if known by him must have materially affected his settlement with the debtor."</p>
<p>THESE LIMITATIONS SHALL APPLY TO THE FULLEST EXTENT PERMITTED BY LAW.</p>
<p>9. INJUNCTIVE RELIEF</p>
You acknowledge and agree that any violation or breach of the TOU may cause the website operator immediate and irreparable harm and damages; consequently, notwithstanding any other provision of the TOU or other applicable legal requirements, the website operator has the right to, and may in its discretion, immediately obtain preliminary injunctive relief (including, without limitation, temporary restraining orders) and seek permanent injunctive relief regarding any violation or breach of the TOU. In addition to any and all other remedies available to the website operator in law or in equity, the website operator may seek specific performance of any term in the TOU, including but not limited to by preliminary or permanent injunction.</p>
<p>10. PRODUCT LIABILITY</p>
<p>You understand and agree that the website operator is not responsible for any food or product made available on the site and hold harmless he website operator and its affiliates from any claim or allegation arising out of a food borne illness or product defect.</p>
<p>The website operator does not inspect any products or food materials. Should you or anyone you know be harmed due to a product made available on the website, please notify us immediately. We will promptly remove the flagged product. This is your sole remedy from the website operator. This language does not restrict your ability to seek legal remedy from the food producer or product distributor itself.</p>
<p>11. MISCELLANEOUS</p> 
<p>These TOU constitute the entire agreement between you and the website operator and supersede any prior written or oral agreement. Other than the Representatives (who are expressly included as named third-party beneficiaries of the TOU), there are no third-party beneficiaries to the TOU.</p>
]

SiteContent.instance.update(
  :about => about,
  :terms_of_service => terms
)
