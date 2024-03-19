import * as React from 'react';
import { useAsyncEffect } from 'use-async-effect';
import { fetchOIDCConfig } from '../server/openid_configuration';
import {
	OIDCContext,
	StateEnum,
	LoginButton,
	IfOIDCState,
	LoggedInUser,
	useOpenIDConnectContext,
} from '@epfl-si/react-appauth';
import { QueryClientGraphQLProvider } from '@epfl-si/react-graphql-paginated';

import { Loading } from './spinner';
import PersonalForm from '../pages/PersonalForm';
import ParamBar from './ParamBar';
import { useForm } from 'react-hook-form';

export function App() {
	const [authServerUrl, setAuthServerUrl] = React.useState<string>();
	const { register, handleSubmit } = useForm();

	useAsyncEffect(async componentIsStillLive => {
		const { auth_server } = await fetchOIDCConfig();
		if (componentIsStillLive()) setAuthServerUrl(auth_server);
	});

	if (!authServerUrl) return <Loading />;

	return (
		<OIDCContext
			authServerUrl={authServerUrl}
			client={{ clientId: 'hello_rails', redirectUri: 'http://localhost:3000/' }}
		>
			<LoginButton inProgressLabel={<Loading />} />
			<IfOIDCState is={StateEnum.LoggedIn}>
				<p>
					Hello, <LoggedInUser field="preferred_username" />!
				</p>
				<QueryClientGraphQLProvider
					endpoint="/graphql"
					authentication={{ bearer: () => useOpenIDConnectContext().accessToken }}
				>
					<form onSubmit={handleSubmit}>
						<ParamBar register={register} />
						<PersonalForm register={register} />
						<button type="submit">Submit</button>
					</form>
				</QueryClientGraphQLProvider>
			</IfOIDCState>
		</OIDCContext>
	);
}
