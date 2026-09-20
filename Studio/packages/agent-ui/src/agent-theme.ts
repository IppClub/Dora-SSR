import {createTheme} from '@mui/material/styles';

export const AgentColor={
  Background:'#1d1d1d',
  BackgroundDark:'#161616',
  SurfaceHover:'#ffffff0a',
  Primary:'#ccc',
  Secondary:'#ccca',
  TextPrimary:'#eee',
  TextSecondary:'#eee8',
  DisabledText:'#9a9a9a',
  DisabledBackground:'#292929',
  DisabledBorder:'#414141',
  Theme:'#fac03d',
  ThemeMuted:'#fac03d1f',
  Line:'#ffffff20',
  Warning:'#ff9800',
} as const;

/** The same MUI theme context that surrounded the original Web IDE composer. */
export const agentTheme=createTheme({
  palette:{
    background:{default:AgentColor.Background,paper:AgentColor.BackgroundDark},
    primary:{main:AgentColor.Primary},
    secondary:{main:AgentColor.Secondary},
    text:{primary:AgentColor.TextPrimary,secondary:AgentColor.TextSecondary},
    action:{
      hover:AgentColor.Theme+'66',
      focus:AgentColor.Theme+'44',
      active:AgentColor.Theme+'22',
      disabled:AgentColor.DisabledText,
      disabledBackground:AgentColor.DisabledBackground,
      disabledOpacity:1,
    },
  },
  components:{
    MuiButtonBase:{defaultProps:{disableRipple:true}},
    MuiButton:{styleOverrides:{root:{
      borderRadius:6,
      textTransform:'none',
      '&.Mui-disabled':{
        color:AgentColor.DisabledText,
        borderColor:AgentColor.DisabledBorder,
        backgroundColor:AgentColor.DisabledBackground,
      },
    }}},
    MuiIconButton:{styleOverrides:{root:{
      '&.Mui-disabled':{
        color:AgentColor.DisabledText,
        borderColor:AgentColor.DisabledBorder,
        backgroundColor:AgentColor.DisabledBackground,
      },
    }}},
  },
});
