function []=TP_correction_PID()

close all;
fprintf('IUT GEII Brest, Septembre 2015\n');

%implementation PID
N=100; % COnstante de temps égal à 1/N pour le filtre de l'action dérivée.

%laplace variable is denoted p
p=tf('p');
transfer_function=1;
correcteur_tf=1;
tableau_marker=[];
init='1/((1+0.1*p)^2)';


%------------------ Creation de l'interface graphique--------------------%
fh = figure('Position',[500 500 1000 800],'Name','Diagramme de Black Nichols');

color=[204 204 204]/255;
min_menu_x=0.05;
min_menu_y=0.05;
width_menu_x=0.22;
width_menu_y=0.07;
width_textbox_x=width_menu_x/2;
width_textbox_y=width_menu_y/2;
menu_vector=[min_menu_x 0.85 width_menu_x width_menu_y];
button_x=150;
button_w=60;
delta=30;   %decallage vertical

%panel pour le system
ph = uipanel('Parent',fh,'Title','Fonction de transfert du système: F(p)','Position',[min_menu_x 0.85 width_menu_x width_menu_y],...
            'BackgroundColor',color);
h1=uicontrol(ph,'Style', 'edit', 'String',init,'Position',[10 10 130 20],'BackgroundColor',[1 1 1]);
h2=uicontrol(ph,'Style', 'pushbutton', 'String','Refresh','Position', [button_x 10 button_w 20],'Callback', @systf);

%panel pour le correcteur
y_pos=100;
width_y=2.71*width_menu_y;
uicontrol_pos=[10 y_pos 130 20];
pc = uipanel('Parent',fh,'Title','Correcteur: C(p)','Position',[min_menu_x 0.65 width_menu_x width_y],...
            'BackgroundColor',color);
h3=uicontrol(pc,'Style', 'text' , 'String','Type:','Position',uicontrol_pos,'BackgroundColor',color,...
             'HorizontalAlignment','right');
h4=uicontrol(pc,'Style', 'popupmenu', 'String',{'aucun','P','PI','PID','Avance de Phase'},'Position', [button_x y_pos button_w 20],...
             'BackgroundColor',[1 1 1],'Callback', @choix_correcteur);
h5=uicontrol(pc,'Style', 'text' , 'String','K:','Position',uicontrol_pos+[0 -delta 0 0],'BackgroundColor',color,...
             'HorizontalAlignment','right');
h6=uicontrol(pc,'Style', 'edit', 'String',1,'Position', [button_x (y_pos-delta) button_w 20],'BackgroundColor',[1 1 1],...
             'Callback', @cortf,'Enable','Off');
h7=uicontrol(pc,'Style', 'text' ,'String','Ti (s):','Position',uicontrol_pos+[0 -2*delta 0 0],'BackgroundColor',color,...
             'HorizontalAlignment','right');
h8=uicontrol(pc,'Style', 'edit', 'String',1,'Position', [button_x (y_pos-2*delta) button_w 20],'BackgroundColor',[1 1 1],...
             'Callback', @cortf,'Enable','Off');
h9=uicontrol(pc,'Style', 'text' ,'String','Td (s):','Position',uicontrol_pos+[0 -3*delta 0 0],'BackgroundColor',color,...
             'HorizontalAlignment','right');
h91=uicontrol(pc,'Style', 'edit', 'String',1,'Position', [button_x (y_pos-3*delta) button_w 20],'BackgroundColor',[1 1 1],...
             'Callback', @cortf,'Enable','Off');
         
%panel pour les paramètres de la boucle fermée
y_pos=y_pos-30;
uicontrol_pos=[10 y_pos 130 20];
bc = uipanel('Parent',fh,'Title','Paramètres en Boucle Fermée','Position',[min_menu_x 0.49 width_menu_x 0.8*width_y],...
                'BackgroundColor',color);
h10=uicontrol(bc,'Style', 'text' , 'String','G0 (dB):','Position',uicontrol_pos,...
                'BackgroundColor',color,'HorizontalAlignment','right');
h11=uicontrol(bc,'Style', 'edit', 'String',' ','Position', [button_x y_pos button_w 20],...
                'BackgroundColor',[1 1 1]);
h12=uicontrol(bc,'Style', 'text' , 'String','Gm(dB):','Position',uicontrol_pos+[0 -delta 0 0],...
                'BackgroundColor',color,'HorizontalAlignment','right');
h13=uicontrol(bc,'Style', 'edit', 'String',' ','Position', [button_x (y_pos-delta) button_w 20],...
                'BackgroundColor',[1 1 1]);
h14=uicontrol(bc,'Style', 'text' , 'String','wr (rad/s):','Position',uicontrol_pos+[0 -2*delta 0 0],...
                'BackgroundColor',color,'HorizontalAlignment','right');
h15=uicontrol(bc,'Style', 'edit', 'String',' ','Position', [button_x (y_pos-2*delta) button_w 20],...
                'BackgroundColor',[1 1 1]);


%panel pour l'ajout des marqueurs
y_pos=80;
length_text_w=50;
uicontrol_pos=[10 y_pos length_text_w 20];

mc = uipanel('Parent',fh,'Title','Marqueurs graphiques','Position',[min_menu_x 0.1 width_menu_x 2*width_y],...
                'BackgroundColor',color);
mc2 = uipanel('Parent',mc,'Title','Coordonnées','Position',[0 0.5 0.65 0.5],'BackgroundColor',color);
h16=uicontrol(mc2,'Style', 'text' , 'String','w (rad/s):','Position',[10 y_pos length_text_w 20],...
                'BackgroundColor',color,'HorizontalAlignment','left');
h17=uicontrol(mc2,'Style', 'edit', 'String',' ','Position', [20+length_text_w y_pos button_w 20],...
                'BackgroundColor',[1 1 1]);
h18=uicontrol(mc2,'Style', 'text' , 'String','G (dB):','Position',[10 y_pos-delta length_text_w 20],...
                'BackgroundColor',color,'HorizontalAlignment','left');
h19=uicontrol(mc2,'Style', 'edit', 'String',' ','Position', [20+length_text_w (y_pos-delta) button_w 20],...
                'BackgroundColor',[1 1 1]);
h20=uicontrol(mc2,'Style', 'text' , 'String','Arg (°):','Position',[10 y_pos-2*delta length_text_w 20],...
                'BackgroundColor',color,'HorizontalAlignment','left');
h21=uicontrol(mc2,'Style', 'edit', 'String',' ','Position', [20+length_text_w (y_pos-2*delta) button_w 20],...
                'BackgroundColor',[1 1 1]);   
            
mc3 = uipanel('Parent',mc,'Title','Action','Position',[0.65 0.5 0.35 0.5],'BackgroundColor',color);            
h22=uicontrol(mc3,'Style', 'pushbutton', 'String','Add','Position', [5 y_pos button_w 20],'Enable','On','Callback',@addmarker); 
h23=uicontrol(mc3,'Style', 'pushbutton', 'String','Modify','Position', [5 (y_pos-delta) button_w 20],'Enable','Off','Callback',@modifymarker);  
h24=uicontrol(mc3,'Style', 'pushbutton', 'String','Remove','Position', [5 (y_pos-2*delta) button_w 20],'Enable','Off','Callback',@removemarker);   

mc4 = uipanel('Parent',mc,'Title','Liste des marqueurs','Position',[0 0 1 0.5],'BackgroundColor',color);

h25=uicontrol(mc,'Style', 'ListBox' , 'String','','Position',[5 5 210 90],...
                 'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Callback',@selectmarker);

            
           
%axes pour diagramme de black nichols
pos_x_axe=(width_menu_x+2*min_menu_x);
set(gca,'Position',[pos_x_axe min_menu_y (1-pos_x_axe-min_menu_x) 0.9]);


%------------------------------------------------------------------------%
%                             Intialisation                              %
%------------------------------------------------------------------------%
%run mefirst
systf([],[]);

    %---------------------------------------------------------------------%
    %                             Nested Function                         %
    %---------------------------------------------------------------------%
    function systf(input1,input2)
            transfer_function=eval(get(h1,'String'));
            dessine();
    end

    function choix_correcteur(input1,input2)
            switch(get(h4,'Value'))
                case 1
                    set(h6,'Enable','Off');
                    set(h8,'Enable','Off');
                    set(h91,'Enable','Off');
                    set(h9,'String','Td');
                case 2
                    set(h6,'Enable','On');
                    set(h8,'Enable','Off');
                    set(h91,'Enable','Off');
                    set(h9,'String','Td');
                case 3
                    set(h6,'Enable','On');
                    set(h8,'Enable','On');
                    set(h91,'Enable','Off'); 
                    set(h9,'String','Td');
                case 4
                    set(h6,'Enable','On');
                    set(h8,'Enable','On');
                    set(h91,'Enable','On'); 
                    set(h9,'String','Td');
                case 5
                    set(h6,'Enable','On');
                    set(h8,'Enable','On'); 
                    set(h91,'Enable','On'); 
                    set(h9,'String','a');
            end
            cortf([],[]);
    end

    function cortf(input1,input2)
            K=str2num(get(h6,'String'));
            Ti=str2num(get(h8,'String'));
            Td=str2num(get(h91,'String'));  %value of Td (PID) or a (PD)
            switch(get(h4,'Value'))
                case 1
                    correcteur_tf=1;
                case 2
                    correcteur_tf=K;
                case 3
                    correcteur_tf=K*(Ti*p+1)/(Ti*p);
                case 4
                    correcteur_tf=K*(1+Ti*p)*(1+Td*p)/((Ti*p)*(1+(1/N)*p));
                case 5
                    correcteur_tf=K*(Td*Ti*p+1)/(1+Ti*p);
            end
            correcteur_tf;
            dessine();
    end

    function dessine()
            nichols(transfer_function,10.^[-5:0.001:5]);
            xlim([-270 0]);
            ylim([-100 40]);
            ngrid;
            %affichage des lieu de transfert
            if (get(h4,'Value')~=1)
               hold on;
               nichols(correcteur_tf*transfer_function,'r',10.^[-5:0.001:5]);
               hold off;
               legend('Système','Système corrigé');
            else
               legend('Système');
            end
            
            %affichage des markers
            hold on;
            for indice=1:size(tableau_marker,1)
                plot(tableau_marker(indice,3),tableau_marker(indice,2),'bo');
            end
            hold off;
  
            %calcul des parametres de la BF    
            calcul();   
    end

    function calcul()
            %Calcul des paramètres de la boucle fermé
            ftbf=(correcteur_tf*transfer_function)/(1+correcteur_tf*transfer_function);
            [mag,phase,w]=bode(ftbf);
            G0_dB=20*log10(mag(1));
            %recherche du maximum
            [G_maximum,index_maxi]=max(mag);
            G_max_dB=20*log10(G_maximum);
            phase_max=phase(index_maxi);
            pulsation=w(index_maxi);
            set(h11,'String',sprintf('%.3f',G0_dB));
            set(h13,'String',sprintf('%.3f',G_max_dB));
            set(h15,'String',sprintf('%.3f',pulsation));

    end


    function addmarker(input1,input2)
      %creation des coordonnées
      tableau_marker_temp(1)=str2num(get(h17,'String'));
      tableau_marker_temp(2)=str2num(get(h19,'String'));
      tableau_marker_temp(3)=str2num(get(h21,'String'));

      %ajout aux tableaux de marker
      index_marker=size(tableau_marker,1)+1;
      tableau_marker(index_marker,:)=tableau_marker_temp;

      %on range tout par ordre des frequences croissantes
      [w_range,index_range]=sort(tableau_marker(:,1),'ascend');
      tableau_marker=tableau_marker(index_range,:);
      createliste();
      index_marker=find(index_range==index_marker);
      set(h25,'Value',index_marker,'max',1,'min',0);
      selectmarker([],[]);
    end

    function selectmarker(input1,input2)
      %recuperation des coordonnées du marker
      dessine();
      if (isempty(tableau_marker)==0)
        index=get(h25,'Value');
        set(h17,'String',tableau_marker(index,1));
        set(h19,'String',tableau_marker(index,2));
        set(h21,'String',tableau_marker(index,3));
        set(h23,'Enable','On');
        set(h24,'Enable','On');
        
        hold on;
        plot(tableau_marker(index,3),tableau_marker(index,2),'ro');
        hold off;
      end
    end

    function removemarker(input1,input2)
      %recuperation de l'index du marker
      index=get(h25,'Value');
      %suppression du marker
      tableau_marker(index,:)=[];
      %creation de la liste
      createliste();
      %selection du marker suivant
      if size(tableau_marker,1)>=1
          set(h25,'Value',max(index-1,1));
      else
        set(h25,'max',2,'min',0);
        set(h25,'Value',[]);
      end
      selectmarker([],[]);
    end

    function modifymarker(input1,input2)
        %recuperation de l'index du marker
        index=get(h25,'Value');
        %suppression du marker
        tableau_marker(index,:)=[];
        %ajout du marker
        addmarker([],[]);
    end

    function createliste()
        %creation de la liste
        if isempty(tableau_marker)==0
            for indice=1:size(tableau_marker,1)
                chaine{indice}=sprintf('w=%.2f,G=%.2f,Arg=%.2f',tableau_marker(indice,1),tableau_marker(indice,2),tableau_marker(indice,3));
            end 
        else    
            chaine{1}='';
            set(h23,'Enable','Off');
            set(h24,'Enable','Off');
        end
        set(h25,'String',chaine);
    end



end
