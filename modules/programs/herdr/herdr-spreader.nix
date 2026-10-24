{
  workspaces = [
    {
      name = "workspace";
      root = "/workspace";
      focus = true;
      tabs = [
        {
          label = "vpn";
          panes = [{}];
        }
        {
          label = "CTF workspace";
          cwd = "/workspace/CTFs";
          panes = [
            {}
            {
              split = "right";
              ratio = 0.5;
              command = "y";
            }
          ];
        }
      ];
    }
    {
      name = "c2";
      root = "/workspace";
      tabs = [
        {
          label = "sliver";
          panes = [{command = "sliver-client";}];
        }
        {
          label = "metasploit";
          panes = [{command = "msfconsole";}];
        }
        {
          label = "layout";
          panes = [
            {}
            {
              split = "right";
              ratio = 0.5;
              command = "penelope -p 9001";
            }
            {
              split = "down";
              ratio = 0.5;
              cwd = "/opt/tools/stagers/linux/";
              command = "python3 server.py";
            }
          ];
        }
      ];
    }
    {
      name = "misc";
      root = "/workspace";
      tabs = [
        {
          label = "main";
          panes = [{}];
        }
      ];
    }
  ];
}
