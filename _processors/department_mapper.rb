# encoding: utf-8
class DepartmentMapper

  RAW_DATA_TO_ABBR = {
    # Unique data values from OSCAR
    "Armed Forces Retired Pay, Pensions etc" => nil,
    "Cabinet Office" => :"CO",
    "Cabinet Office: Civil Superannuation" => :"CO",
    "Charity Commission" => nil,
    "Crown Estate Office" => nil,
    "Crown Prosecution Service" => nil,
    "Department for Business Innovation and Skills" => :"BIS",
    "Department for Communities and Local Government" => :"DCLG",
    "Department for Culture, Media and Sport" => :"DCMS",
    "Department for Education" => :"DFE",
    "Department for Environment, Food and Rural Affairs" => :"DEFRA",
    "Department for International Development" => :"DFID",
    "Department for International Development: Overseas Superannuation" => :"DFID",
    "Department for Transport" => :"DFT",
    "Department for Work and Pensions" => :"DWP",
    "Department of Energy and Climate Change" => :"DECC",
    "Department of Health" => :"DH",
    "Export Credits Guarantee Department" => nil,
    "Food Standards Agency" => nil,
    "Foreign and Commonwealth Office" => :"FCO",
    "Government Actuary's Department" => nil,
    "HM Procurator General and Treasury Solicitor" => nil,
    "HM Revenue and Customs" => :HMRC,
    "HM Treasury" => :"HMT",
    "Home Office" => :"HO",
    "Independent Parliamentary Standards Authority" => nil,
    "Ministry of Defence" => :"MOD",
    "Ministry of Justice" => :"MOJ",
    "Ministry of Justice: Judicial Pensions Scheme" => :"MOJ",
    "National Audit Office" => nil,
    "National Health Service Pension Scheme" => nil,
    "Northern Ireland Executive" => nil,
    "Northern Ireland Office" => :"NIO",
    "Office for National Statistics" => nil,
    "Office for Standards In Education, Children's Services and Skills" => nil,
    "Office of Fair Trading" => nil,
    "Office of Gas and Electricity Markets" => nil,
    "Office of The Parliamentary Commissioner" => nil,
    "Royal Mail Statutory Pension Scheme" => nil,
    "Scotland Office and Office of the Advocate General" => :"OAG",
    "Scottish Government" => nil,
    "Serious Fraud Office" => nil,
    "Teachers' Pension Scheme (England and Wales)" => nil,
    "The National Archives" => nil,
    "Uk Trade & Investment" => nil,
    "United Kingdom Atomic Energy Authority Pension Schemes" => nil,
    "United Kingdom Supreme Court" => nil,
    "Wales Office" => :"WO",
    "Water Services Regulation Authority" => nil,
    "Welsh Assembly Government" => nil,

    # Unique values from QDS
    "BIS" => :"BIS",
    "CO" => :"CO",
    "DCLG" => :"DCLG",
    "DCMS" => :"DCMS",
    "DECC" => :"DECC",
    "DEFRA" => :"DEFRA",
    "DFE" => :"DFE",
    "DfE" => :"DFE",
    "DFID" => :"DFID",
    "DFT" => :"DFT",
    "DfT" => :"DFT",
    "DH" => :"DH",
    "DWP" => :"DWP",
    "FCO" => :"FCO",
    "HCA" => :HCA,
    "HMRC" => :"HMRC",
    "HMT" => :"HMT",
    "HO" => :"HOME OFFICE",
    "Local Govt" => :"DCLG",
    "MOD" => :"MOD",
    "MoJ" => :"MOJ",
    "MOJ" => :"MOJ",
    "NDA" => :"DECC",
    "PINS" => :"DCLG"
  }

  ABBR_TO_HASH = {
    :"AGO"                 => { :name => "Attorney Generals Office",                          :css_class => "attorney-generals-office",                         :css_logo_suffix => "single-identity", :colour => "#215936", :font_colour => "#fff" },
    :"CO"                  => { :name => "Cabinet Office",                                    :css_class => "cabinet-office",                                   :css_logo_suffix => "single-identity", :colour => "#0078ba", :font_colour => "#fff" },
    :"BIS"                 => { :name => "Department for Business Innovation Skills",         :css_class => "department-for-business-innovation-skills",        :css_logo_suffix => "bis",             :colour => "#3a6f8c", :font_colour => "#fff" },
    :"DCLG"                => { :name => "Department for Communities and Local Government",   :css_class => "department-for-communities-and-local-government",  :css_logo_suffix => "single-identity", :colour => "#4a338c", :font_colour => "#fff" },
    :"DCMS"                => { :name => "Department for Culture Media Sport",                :css_class => "department-for-culture-media-sport",               :css_logo_suffix => "single-identity", :colour => "#ee1089", :font_colour => "#0A0C0C" },
    :"DFE"                 => { :name => "Department for Education",                          :css_class => "department-for-education",                         :css_logo_suffix => "single-identity", :colour => "#f6823e", :font_colour => "#0A0C0C" },
    :"DEFRA"               => { :name => "Department for Environment Food Rural Affairs",     :css_class => "department-for-environment-food-rural-affairs",    :css_logo_suffix => "single-identity", :colour => "#8a8c30", :font_colour => "#0A0C0C" },
    :"DFID"                => { :name => "Department for International Development",          :css_class => "department-for-international-development",         :css_logo_suffix => "single-identity", :colour => "#729ecd", :font_colour => "#0A0C0C" },
    :"DFT"                 => { :name => "Department for Transport",                          :css_class => "department-for-transport",                         :css_logo_suffix => "single-identity", :colour => "#007162", :font_colour => "#fff" },
    :"DWP"                 => { :name => "Department for Work Pensions",                      :css_class => "department-for-work-pensions",                     :css_logo_suffix => "single-identity", :colour => "#16bcb8", :font_colour => "#0A0C0C" },
    :"DECC"                => { :name => "Department of Energy Climate Change",               :css_class => "department-of-energy-climate-change",              :css_logo_suffix => "single-identity", :colour => "#78c059", :font_colour => "#0A0C0C" },
    :"DH"                  => { :name => "Department of Health",                              :css_class => "department-of-health",                             :css_logo_suffix => "single-identity", :colour => "#00ae9f", :font_colour => "#0A0C0C" },
    :"FCO"                 => { :name => "Foreign Commonwealth Office",                       :css_class => "foreign-commonwealth-office",                      :css_logo_suffix => "single-identity", :colour => "#00569e", :font_colour => "#fff" },
    :"HMT"                 => { :name => "HM Treasury",                                       :css_class => "hm-treasury",                                      :css_logo_suffix => "single-identity", :colour => "#c03024", :font_colour => "#fff" },
    :"HOME OFFICE"         => { :name => "Home Office",                                       :css_class => "home-office",                                      :css_logo_suffix => "ho",              :colour => "#804292", :font_colour => "#fff" },
    :"MOD"                 => { :name => "Ministry of Defence",                               :css_class => "ministry-of-defence",                              :css_logo_suffix => "mod",             :colour => "#5d2a44", :font_colour => "#fff" },
    :"MOJ"                 => { :name => "Ministry of Justice",                               :css_class => "ministry-of-justice",                              :css_logo_suffix => "single-identity", :colour => "#231f20", :font_colour => "#fff" },
    :"NIO"                 => { :name => "Northern Ireland Office",                           :css_class => "northern-ireland-office",                          :css_logo_suffix => "single-identity" },
    :"OAG"                 => { :name => "Office of the Advocate General for Scotland",       :css_class => "office-of-the-advocate-general-for-scotland",      :css_logo_suffix => "so"              },
    :"OLHC"                => { :name => "The Office of the Leader of the House of Commons",  :css_class => "the-office-of-the-leader-of-the-house-of-commons", :css_logo_suffix => "portcullis"      },
    :"OLHL"                => { :name => "Office of the Leader of the House of Lords",        :css_class => "office-of-the-leader-of-the-house-of-lords",       :css_logo_suffix => "portcullis"      },
    :"SCOTLAND OFFICE"     => { :name => "Scotland Office",                                   :css_class => "scotland-office",                                  :css_logo_suffix => "so"              },
    :"UK EXPORT FINANCE"   => { :name => "Export Credit Guarantee Department",                :css_class => "export-credit-guarantee-department",               :css_logo_suffix => "single-identity" },
    :"WO"                  => { :name => "Wales Office",                                      :css_class => "wales-office",                                     :css_logo_suffix => "wales"           },

    :"HMRC"                => { :name => "HM Revenue & Customs" },
    :"HCA"                 => { :name => "Homes and Communities Agency",                      :css_class => "homes-and-communities-agency",                     :css_logo_suffix => "single-identity" }
  }

  def self.map_raw_to_css_hash(raw_department)
    raw_key = RAW_DATA_TO_ABBR.keys.detect{ |k| k.upcase == raw_department.upcase }
    if raw_key
      abbr = RAW_DATA_TO_ABBR[raw_key]
      if abbr && ABBR_TO_HASH[abbr]
        return { :abbr => abbr.to_s }.merge(ABBR_TO_HASH[abbr])
      end
    end
    nil
  end

end