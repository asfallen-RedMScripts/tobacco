Config = {}

-- Sigara / puro yakmak için kibrit
Config.ItemNeed  = "allumettes"   -- tüm “Smoke” işlemlerinde önce kibrit aranacak

-- Pipe Smoker için de tütün
Config.ItemNeed2 = "tabacpipe"    -- sadece pipe_smoker'da bu tütün eksilecek

Config.Prompts = { 
    Drop     = "Söndür",                   
    DropKey  = 0x3B24C470,                
    Smoke    = "Kullan",                  
    SmokeKey = 0x07B8BEAF,                
    Change   = "Pozisyonu değiştir",      
    ChangeKey= 0xD51B784F,                
}

Config.Text = {
    Pipe        = "Piponu yakmak için kuru tütün ve kibrite ihtiyacın var!",
    Cigar       = "Puronu yakmak için kibrite ihtiyacın var!",
    Allumettes  = "Kibrite ihtiyacın var...",
    Empty       = "Paketin bitti!",
    Text1       = "Artık 9 tane sigara kaldı",
    Text2       = "Artık 8 tane sigara kaldı",
    Text3       = "Artık 7 tane sigara kaldı",
    Text4       = "Artık 6 tane sigara kaldı",
    Text5       = "Artık 5 tane sigara kaldı",
    Text6       = "Artık 4 tane sigara kaldı",
    Text7       = "Artık 3 tane sigara kaldı",
    Text8       = "Artık 2 tane sigara kaldı",
    Text9       = "Artık 1 tane sigara kaldı",
    TextA       = "4 doz kaldı",
    TextB       = "3 doz kaldı",
    TextC       = "2 doz kaldı",
    TextD       = "1 doz kaldı",
    Empty2      = "Son dozdu!",
}
