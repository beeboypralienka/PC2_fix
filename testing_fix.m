        %----------------------------------------------------------------
        % Hitung hamming distance TESTING terhadap titik C1 dan C2 temp
        %----------------------------------------------------------------        
        PC2_38________________________ = 0;        
        for iKolomCluster = 1 : iFitur
            for iBarisCluster = 1 : size(PC2_03_Test{1,iFitur}{iFold,1},1)              
                %--------------------------------------------
                % Hitung jarak data TESTING ke titik cluster
                %--------------------------------------------
                data = PC2_03_Test{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);

                %--------------------------------
                % Jarak tiap fitur TESTING ke C1
                %--------------------------------
                C1 = PC2_31_Titik_C1_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C1);
                PC2_39_Test_HamDist_C1{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;

                %--------------------------------
                % Jarak tiap fitur TESTING ke C2
                %--------------------------------
                if size(PC2_32_Titik_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                                        
                    C2 = PC2_32_Titik_C2_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                    jarakHamming = hammingDistance_fix(data,C2);
                    PC2_40_Test_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;
                else
                    PC2_40_Test_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = 999999;
                end                
            end 
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(:,1) = mean(PC2_39_Test_HamDist_C1{1,iFitur}{iFold,1},2); % Rata-rata per baris        
        PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(:,2) = mean(PC2_40_Test_HamDist_C2{1,iFitur}{iFold,1},2); % Rata-rata per baris
        
        %-------------------------------------------------------------------
        % Penentuan anggota C1 atau C2 berdasarkan jarak rata-rata terdekat
        %-------------------------------------------------------------------
        for iBarisAvg = 1 : size(PC2_03_Test{1,iFitur}{iFold,1},1)
            averageC1 = PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,1);
            averageC2 = PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,2);                                    
            if averageC1 > averageC2                
                PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
                PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,4) = PC2_03_Test{1,iFitur}{iFold,1}(iBarisAvg,end-1); %Penambahan kelas sebagai ground truth
            else
                PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
                PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,4) = PC2_03_Test{1,iFitur}{iFold,1}(iBarisAvg,end-1); %Penambahan kelas sebagai ground truth
            end                                                              
        end
        clear iBarisAvg averageC1 averageC2;       
        
        %-----------------------------------------------------------------------
        % Pengelompokan data "C1_Test" dan "C2_Test" berdasarkan 11111 dan 22222
        %-----------------------------------------------------------------------
        fgC1 = 0;
        fgC2 = 0;
        for iBarisKelompok = 1 : size(PC2_03_Test{1,iFitur}{iFold,1},1)              
            if PC2_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111                     
                fgC1 = fgC1 + 1;
                PC2_42_Test_Anggota_C1{1,iFitur}{iFold,1}(fgC1,:) = PC2_03_Test{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
            else     
                fgC2 = fgC2 + 1;
                PC2_43_Test_Anggota_C2{1,iFitur}{iFold,1}(fgC2,:) = PC2_03_Test{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                             
            end                                                                  
        end           
        
        %----------------------------------------------------------------------
        % Cek kalau avg kelompoknya C2 semua atau C1 semua,
        % tar dibuat matrik kosong, soalnya matlab menganggap tidak ada matrik
        %----------------------------------------------------------------------
        if fgC1 == size(PC2_03_Test{1,iFitur}{iFold,1},1)
            PC2_43_Test_Anggota_C2{1,iFitur}{iFold,1} = [];                 
        elseif fgC2 == size(PC2_03_Test{1,iFitur}{iFold,1},1)
            PC2_42_Test_Anggota_C1{1,iFitur}{iFold,1} = [];
        end
        clear fgC1 fgC2 iBarisKelompok;                                          
                                
%==============================================================================================
%                              ==  PC2_45_TP_ && PC2_46_FP_  ===
%==============================================================================================         

        %-----------------------------------------
        % Kalau anggota C2 emang gada sama sekali
        %-----------------------------------------
        countTP = 0;
        countFP = 0;
        if size(PC2_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) == 0
            PC2_45_TP_{1,iFitur}{iFold,1} = 0;
            PC2_46_FP_{1,iFitur}{iFold,1} = 0;
        %---------------------------------------    
        % Ada anggota C2, maka hitung TP dan FP
        %---------------------------------------
        else 
            %--------------------------------
            % Cek anggota C2 untuk TP dan FP
            %--------------------------------
            for iBarisC2 = 1 : size(PC2_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
                if PC2_43_Test_Anggota_C2{1,iFitur}{iFold,1}(iBarisC2,iFitur+1) == 1
                    countTP = countTP + 1;
                    PC2_45_TP_{1,iFitur}{iFold,1} = countTP;
                else
                    countFP = countFP + 1;
                    PC2_46_FP_{1,iFitur}{iFold,1} = countFP;
                end            
            end                                          
        end
        %--------------------------------------------------
        % Kondisi kalau kelasnya 0 semua atau 1 semua di C2
        %--------------------------------------------------
        if countFP == size(PC2_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
            PC2_45_TP_{1,iFitur}{iFold,1} = 0;
        elseif countTP == size(PC2_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
            PC2_46_FP_{1,iFitur}{iFold,1} = 0;
        end
        clear countTP countFP iBarisC2;
                               
%==============================================================================================
%                             ==  PC2_47_FN_ && PC2_48_TN_  ===
%============================================================================================== 
              
        %-----------------------------------------
        % Kalau anggota C1 emang gada sama sekali
        %-----------------------------------------
        countFN = 0;
        countTN = 0;   
        if size(PC2_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) == 0
            PC2_47_FN_{1,iFitur}{iFold,1} = 0;
            PC2_48_TN_{1,iFitur}{iFold,1} = 0;
        %----------------
        % C1 ada anggota
        %----------------
        else    
            %--------------------------------
            % Cek anggota C2 untuk FN dan TN
            %--------------------------------
            for iBarisC2 = 1 : size(PC2_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
                if PC2_42_Test_Anggota_C1{1,iFitur}{iFold,1}(iBarisC2,iFitur+1) == 1
                    countFN = countFN + 1;
                    PC2_47_FN_{1,iFitur}{iFold,1} = countFN;                
                else
                    countTN = countTN + 1;
                    PC2_48_TN_{1,iFitur}{iFold,1} = countTN;
                end            
            end                    
        end  
        %--------------------------------------------------
        % Kondisi kalau kelasnya 0 semua atau 1 semua di C1
        %--------------------------------------------------
        if countFN == size(PC2_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
            PC2_48_TN_{1,iFitur}{iFold,1} = 0;
        elseif countTN == size(PC2_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
            PC2_47_FN_{1,iFitur}{iFold,1} = 0;
        end
        clear countFN countTN iBarisC2;
        
%==============================================================================================
%                                ==  PC2_49_PD && PC2_50_PF  ===
%==============================================================================================
        
        %-----------------
        % PD = tp/(tp+fn)
        %-----------------
        if  PC2_45_TP_{1,iFitur}{iFold,1} == 0
            PC2_49_PD{1,iFitur}(iFold,1) = 0;
        else
            PC2_49_PD{1,iFitur}(iFold,1) = PC2_45_TP_{1,iFitur}{iFold,1}/(PC2_45_TP_{1,iFitur}{iFold,1} + PC2_47_FN_{1,iFitur}{iFold,1});
        end        
        %---------
        % Mean PD
        %---------
        PC2_50_Mean_PD(1,iFitur) = (mean(PC2_49_PD{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
        %-----------------
        % PF = fp/(fp+tn)        
        %-----------------
        PC2_51_PF{1,iFitur}(iFold,1) = PC2_46_FP_{1,iFitur}{iFold,1}/(PC2_46_FP_{1,iFitur}{iFold,1} + PC2_48_TN_{1,iFitur}{iFold,1});
        %---------
        % Mean PF
        %---------
        PC2_52_Mean_PF(1,iFitur) = (mean(PC2_51_PF{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
        %-----------------------------------------------------
        % Balance = 1 - ( sqrt((0-pf)^2+(1-pd)^2) / sqrt(2) )
        %-----------------------------------------------------        
        PC2_53_BAL{1,iFitur}(iFold,1) = 1 - ( sqrt( ((0 - PC2_51_PF{1,iFitur}(iFold,1))^2) + ((1 - PC2_49_PD{1,iFitur}(iFold,1))^2) ) / sqrt(2) );
        %--------------
        % Mean Balance
        %--------------
        PC2_54_Mean_BAL(1,iFitur) = (mean(PC2_53_BAL{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping