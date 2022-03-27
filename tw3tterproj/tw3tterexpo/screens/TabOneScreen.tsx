import { StyleSheet, Switch, Image} from 'react-native';
import { Text, View } from '../components/Themed';
import { RootTabScreenProps } from '../types';
import { FontAwesome5 } from '@expo/vector-icons';
import React, { useState } from 'react';
import { Pressable, Hoverable, } from "react-native-web-hover";

import { FiMoreHorizontal } from 'react-icons/fi';
import { VscTwitter } from 'react-icons/vsc';



export default function TabOneScreen({ navigation }: RootTabScreenProps<'TabOne'>) {

  const [isPressed, setPressed] = useState(false);
  const toggleSwitch = () => setPressed(previousState => !previousState);

  return (
    <View style={styles.container}>
      {/* <Switch
        ios_backgroundColor="#3e3e3e"
        onValueChange={toggleSwitch}
        value={isPressed}
      /> */}
      <View style={[styles.tw3tterIconContainer]}>
        <Pressable
          style={({ pressed }) => [
            {
              backgroundColor: pressed
                ? 'rgb(210, 230, 255)'
                : 'white'
            },
            styles.wrapperCustom
          ]}>
          {({ pressed }) => (
            <FontAwesome5 name="dragon" size={24} color="green" />
          )}
      </Pressable>
      </View>
      <View style={[styles.tw3tterIconContainer]}>
        <FontAwesome5 name="home" size={24} color="white" />
        <Text>Home</Text>
      </View>
       
    {/* // wrapper: [tw`flex-[0.7] px-8 flex flex-col`],
    // tw3tterIconContainer: [tw`text-3xl m-4`],
    // tw33tButton: [tw`bg-[#1d9bf0] hover:bg-[#1b8cd8] flex items-center justify-center font-bold
    // rounded-3xl h-[50px] mt-[20px] cursor-pointer`],
    // navcontainer: [tw`flex-1`],
    // profileButton: [tw`flex items-center mb-6 cursor-pointer hover:bg-[#333c45] rounded-[100px] p-2`],
    // profileLeft: [`flex item-center justify-center mr-4`],
    // profileImage: [tw`height-12 w-12 rounded-full`],
    // profileRight: [tw`flex-1 flex`],
    // name: [tw`text-lg`],
    // handle: [tw`text-[#8899a6]`],
    // moreContainer: [tw`flex items-center mr-2`], */}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // flexDirection: 'row',
    padding: 40,
    backgroundColor: '#15202b',
    // alignItems: 'center',
    // justifyContent: 'center',
    // justifyContent: 'space-between',
  }, 
  wrapper: {

  },
  wrapperCustom: {
    borderRadius: 8,
    padding: 6
  },
  tw3tterIconContainer: {
    padding: 8,
    fontSize: 30,
    fontWeight: 'bold',
    margin: 4,

    
  },
  navContainer: {
    
  },

  tw33tButton: {
   
  },
  



  separator: {
    marginVertical: 30,
    height: 1,
    width: '80%',
  },
});
